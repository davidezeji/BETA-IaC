import json
import gcip

############
# This Python script is run during a downstream pipeline and will create a dynamic Gitlab CI file
# that will be executed to create an additional downstream pipeline. The current execution will only
# include accounts with ("ekscluster": true). 
############

# Open accounts.json file
with open('aws_accounts.json', 'r') as f:
  accounts = json.load(f)
# Create Pipeline variables for account_vendor_config.yml
account_vendor_pipeline = gcip.Pipeline()
account_vendor_config_folder = "accountVendorConfiguration"
account_vendor_config_script = "vendor_config_setup.sh"
eks_folder = "ekscluster"

# This region list is checked against for each when looping through the provided JSON file.
# If certain regions will not be in use they should not be in this list.
region_list = ["us-west-1", "us-west-2", "us-east-1", "us-east-2"]

# Create list of accounts from aws_accounts.json
# with ==> "ekscluster": true. 
create_eks_cluster = []
for account_type in accounts["accounts"]:
    for account in accounts["accounts"][account_type]:
        for region in region_list:
            for region_k,region_v in accounts["accounts"][account_type][account].items():
                if region == region_k:
                    for k,v in region_v.items():
                        if k == "ekscluster":
                            if v == True:
                                create_eks_cluster.append(account)

############
# Function to create PLAN stages
############
def plan_job(account: str, resource_type: str, pipeline: str, folder: str, script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-{resource_type}-plan", script=f'terraform plan -out ../../{account}-infra.plan')
    job.set_image("alpine:latest")
    ### The prepend_scripts add in reverse order, so read from bottom to top in this block ###
    job.prepend_scripts(f"terraform init -backend-config=../config.gitlab.tfbackend")
    job.prepend_scripts(f"cat ../../specific_vendor.json")
    job.prepend_scripts(f"cd {resource_type}")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    # This sets the Need section of the stage. This pulls in the artifact from the Parent pipeline
    job.add_needs(gcip.Need(job="vendorConfig-CI", pipeline="$ACCOUNT_CONFIG_PIPELINE_ID"))
    # This creates the artifacts for account.plan
    job.artifacts.name = f"{account}-{resource_type}-plan"
    job.artifacts.expire_in = "1 day"
    job.artifacts.add_paths(f"{folder}/{resource_type}")
    job.artifacts.add_paths(f"aws_accounts.json")
    # job.append_rules(gcip.Rule(when=gcip.WhenStatement.MANUAL))
    # This adds the job into the pipeline
    pipeline.add_children(job)

############
# Function to create APPLY stages
############
def apply_job(account: str, resource_type: str, pipeline: str, folder: str, script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-{resource_type}-apply", script=f"cat {account}.json")
    job.set_image("alpine:latest")
    ### The prepend_scripts add in reverse order, so read from bottom to top in this block ###
    job.prepend_scripts(f"terraform output -json > {account}.json")
    job.prepend_scripts(f"terraform apply -auto-approve")
    job.prepend_scripts(f"terraform init -backend-config=../config.gitlab.tfbackend")
    job.prepend_scripts(f"cat ../../specific_vendor.json")
    job.prepend_scripts(f"cd {resource_type}")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    # Create dependency on planning stage
    job.add_needs(gcip.Need(f"{account}-{resource_type}-plan"))
    # This creates the artifacts for account.plan
    job.artifacts.name = f"{account}-details"
    job.artifacts.expire_in = "1 day"
    job.artifacts.add_paths(f"aws_accounts.json")
    pipeline.add_children(job)

############
# Function to create DESTROY stages
# This stage specifically cleans up Multus Resources and may need updates if new stages are added
# This stage should be used when a apply is successful
############
def destroy_job(account: str, resource_type: str, pipeline: str, folder: str, script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-{resource_type}-destroy", script=f'terraform destroy -auto-approve')
    job.set_image("alpine:latest")
    ### The prepend_scripts add in reverse order, so read from bottom to top in this block ###
    # One the ASG has scaled down the interfaces need to be cleaned up. At this point Terraform Destroy should run without issue.
    job.prepend_scripts(f'python3 unused_eni_cleanup.py')
    # Terraform cannot destroy successfully because the ASG instances have an ENI attached. This will scale
    # the cluster to 0 and allow for proper cleanup.
    job.prepend_scripts(f'terraform apply -var "min_size=0" -var "desired_size=0" -auto-approve')
    job.prepend_scripts(f"terraform init -backend-config=../config.gitlab.tfbackend")
    job.prepend_scripts(f"cd {resource_type}")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    job.append_rules(gcip.Rule(when=gcip.WhenStatement.MANUAL))
    job.add_needs(gcip.Need(f"{account}-{resource_type}-plan"))
    pipeline.add_children(job)

############
# Function to create DESTROY stages
# This stage is only used if the apply failed and needs to be cleaned up.
############
def destroy_job_fail(account: str, resource_type: str, pipeline: str, folder: str, script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-{resource_type}-destroy-failure", script=f'terraform destroy -auto-approve')
    job.set_image("alpine:latest")
    job.prepend_scripts(f"terraform init -backend-config=../config.gitlab.tfbackend")
    job.prepend_scripts(f"cd {resource_type}")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    job.append_rules(gcip.Rule(when=gcip.WhenStatement.MANUAL))
    job.add_needs(gcip.Need(f"{account}-{resource_type}-plan"))
    pipeline.add_children(job)

############
# Create Plan, Apply, Destroy Stages for account_config.yml
############
# Loop through list of accounts with ("ekscluster": true) and create stages for each.
for account in create_eks_cluster:
    plan_job(account, eks_folder, account_vendor_pipeline, account_vendor_config_folder, account_vendor_config_script)
    apply_job(account, eks_folder, account_vendor_pipeline, account_vendor_config_folder, account_vendor_config_script)
    destroy_job(account, eks_folder, account_vendor_pipeline, account_vendor_config_folder, account_vendor_config_script)
    destroy_job_fail(account, eks_folder, account_vendor_pipeline, account_vendor_config_folder, account_vendor_config_script)
    
# Write the pipeline variable to YAML
account_vendor_pipeline.write_yaml("account_vendor_config.yml")

# Closing file
f.close()