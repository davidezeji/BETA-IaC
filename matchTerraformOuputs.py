import json
import boto3

# Each account will be added to the empty active_accounts list
active_accounts = []
# This region list is checked against for each when looping through the provided JSON file.
# If certain regions will not be in use they should not be in this list.
region_list = ["us-west-1", "us-west-2", "us-east-1", "us-east-2"]

# Open aws_accounts.json file
with open('aws_accounts.json', 'r') as f:
  terraform_json = json.load(f)

# Open accounts.json file. 
# This file is created within the pipeline stage 'tf_parent_vpc_apply'
# The file contains the Terraform output from the VPC creation in the parent account.
with open('accounts.json', 'r') as f:
  terraform_output_json = json.load(f)

# Pull in Active AWS Accounts and populate active_accounts list
# This will pull in all active AWS Accounts uskng boto3
org_client = boto3.client('organizations')
response = org_client.list_accounts()
for account in response["Accounts"]:
    if account["Status"] == "ACTIVE":
        active_accounts.append(account)

# Match accounts.json with active_accounts list.
# Account Numbers will be associated to each Account and added to the new JSON artifact.
for acct in active_accounts:
    for account_type in terraform_json["accounts"]:
        for account in terraform_json["accounts"][account_type]:
            if account == acct["Name"]:
                terraform_json["accounts"][account_type][account]["account_id"]=acct["Id"]

# Append values of Terraform Output for VPCs/Subnets/RamShares/Tagging
# These values are necessary inputs in later stages and will fill out the aws_accounts.json artifact
# Loop through aws_accounts.json
for account_type in terraform_json["accounts"]:
    for account in terraform_json["accounts"][account_type]:
        # Loop through Terraform Output and add values to aws_accounts.json    
        for output in terraform_output_json:
            # Create loop of region list to ensure resources are assigned to the proper region block
            for region in region_list:
                if "vpc" in output and region in terraform_output_json[output]["value"][account_type][0]["arn"]:
                    terraform_json["accounts"][account_type][account][region][output]=terraform_output_json[output]["value"][account_type][0]["id"]
                    terraform_json["accounts"][account_type][account][region][f"{output}_tags"]=terraform_output_json[output]["value"][account_type][0]["tags_all"]
                # Conditional to check if it's a subnet resource and properly map to the right region block
                if "subnet" in output and region in terraform_output_json[output]["value"][account_type][0][account]["arn"]:
                    terraform_json["accounts"][account_type][account][region][output]=terraform_output_json[output]["value"][account_type][0][account]["id"]
                    # Skip tags for ram resources
                    if "ram" in output:
                        pass
                    # Add tagging information into the region block of the accounts
                    else:
                        terraform_json["accounts"][account_type][account][region][f"{output}_tags"]=terraform_output_json[output]["value"][account_type][0][account]["tags_all"]                    

# Output changes to aws_accounts.json
with open("aws_accounts.json", "w") as f:
    json.dump(terraform_json, f)

# Closing file
f.close()