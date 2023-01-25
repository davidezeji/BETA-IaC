import json
import gcip

############
# This Python script is run to create a dynamic downstream pipeline that will execute against each
# Account within the aws_accounts.json file. The Terraform stages will run against each account to
# setup desired guardrails like AWS Config, CloudTrail, IAM Roles, etc.
# Existing code within the 'account_config_folder' is currently only applying an example IAM Role.
############

# Open accounts.json file
with open('aws_accounts.json', 'r') as f:
  accounts = json.load(f)

# Create list of accounts from aws_accounts.json
account_list = []
for account_type in accounts["accounts"]:
    for account in accounts["accounts"][account_type].keys():
        account_list.append(account)

# Create Pipeline variables for account_config.yml
account_config_pipeline = gcip.Pipeline()
account_config_folder = "accountConfiguration"
account_config_script = "acct_config_setup.sh"
subnet_tagging_script = "assignSubnetTags.py"

############
# Create initial stage to prepare account_vendor_config.yml
# Running this first allows the next stage of plan to easily all run in parallel
# The stage will create the file necessary for the ISV specific downstream pipeline to execute.
############
ci_job = gcip.Job(stage=f"vendorConfig-CI", script=f"python3 accountVendorConfig.py")
ci_job.set_image("alpine:latest")
# Configure Runner for GCIP Python
ci_job.prepend_scripts(f"pip3 install gcip")
ci_job.prepend_scripts(f"pip3 install --upgrade boto3")
ci_job.prepend_scripts(f"apk add -q curl jq python3 py3-pip")
# This sets the Need section of the stage. This pulls in the artifact from the Parent pipeline
ci_job.add_needs(gcip.Need(job="tf_parent_vpc_apply", pipeline="$PARENT_PIPELINE_ID"))
# This creates the artifacts for account.plan
ci_job.artifacts.name = "VendorConfig"
ci_job.artifacts.expire_in = "1 day"
ci_job.artifacts.add_paths(f"account_vendor_config.yml")
ci_job.artifacts.add_paths("aws_accounts.json")
account_config_pipeline.add_children(ci_job)

############
# Function to create PLAN stages
############
def plan_job(account: str, pipeline: str, folder: str, script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-plan", script=f"terraform plan -out ../{account}.plan")
    job.set_image("alpine:latest")
    ### The prepend_scripts add in reverse order, so read from bottom to top in this block ###
    job.prepend_scripts(f"terraform init -backend-config=config.gitlab.tfbackend")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    # This sets the Need section of the stage. This pulls in the artifact from the Parent pipeline
    job.add_needs(gcip.Need(job="tf_parent_vpc_apply", pipeline="$PARENT_PIPELINE_ID"))
    # This creates the artifacts for account.plan
    job.artifacts.name = f"{account}.plan"
    job.artifacts.expire_in = "1 day"
    job.artifacts.add_paths(f"{account}.plan")
    job.artifacts.add_paths(f"aws_accounts.json")
    ### Unused Code Examples ###
    # job.append_scripts("./after-script.sh")
    # job.add_variables(USER="Max Power", URL="https://example.com")
    # job.add_tags("test", "europe")
    # job.append_rules(gcip.Rule(if_statement="$MY_VARIABLE_IS_PRESENT"))
    pipeline.add_children(job)

############
# Function to create APPLY stages
############
def apply_job(account: str, pipeline: str, folder: str, script: str, subnet_script: str) -> gcip.Job:
    job = gcip.Job(stage=f"{account}-apply", script=f"terraform apply ../{account}.plan")
    job.set_image("alpine:latest")
    ### The prepend_scripts add in reverse order, so read from bottom to top in this block ###
    job.prepend_scripts(f"terraform init -backend-config=config.gitlab.tfbackend")
    job.prepend_scripts(f"python3 {subnet_script}")
    job.prepend_scripts("# Assigning Subnet Tags to Shared Subnets/VPC")
    job.prepend_scripts(f". {script}")
    job.prepend_scripts(f"cd {folder}")
    job.prepend_scripts(f"cat aws_accounts.json")
    job.prepend_scripts(f"export ACCOUNT={account}")
    ### ↑↑↑ End of prepend_scripts ###
    job.add_needs(gcip.Need(f"{account}-plan"))
    pipeline.add_children(job)

############
# Create Plan and Apply Stages for account_config.yml
# There is currently no destroy stage as the only resource is an IAM role. As additional configurations
# are added this may need to be updated.
############
# Plan/Apply job creations
for account in account_list:
    plan_job(account, account_config_pipeline, account_config_folder, account_config_script)
    apply_job(account, account_config_pipeline, account_config_folder, account_config_script, subnet_tagging_script)

############
# Create trigger to start Account_Vendor_Config Deployments
# Required gcip version 2.1.1
# This job will take the newly created account_vendor_config.yml and trigger another ISV
# specific downstream pipeline.
############
trigger_job = gcip.TriggerJob(stage="account_vendor_pipeline_trigger", includes=gcip.IncludeArtifact("vendorConfig-CI" ,"account_vendor_config.yml"))
# Create Variable with Pipeline ID which is used to pass these
# artifacts to the Account Vendor Pipeline
trigger_job.add_variables(ACCOUNT_CONFIG_PIPELINE_ID="$CI_PIPELINE_ID")
account_config_pipeline.add_children(trigger_job)

# Write the pipeline variable to YAML
account_config_pipeline.write_yaml("account_config.yml")

# Closing file
f.close()