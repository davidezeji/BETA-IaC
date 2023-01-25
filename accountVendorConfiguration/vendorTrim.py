import json
import os

# Each Account Configuration will have the $ACCOUNT variable
# set, this will pull that information
AWS_ACCOUNT=os.environ["ACCOUNT"]
region_list = ["us-west-1", "us-west-2", "us-east-1", "us-east-2"]
private_app_subnets = []
multus_subnets = []

# Open aws_accounts.json file
with open('../aws_accounts.json', 'r') as f:
  terraform_json = json.load(f)

AWS_ACCOUNT_DICT = {}

for account_type in terraform_json["accounts"]:
    # print(json.dumps(account_type, indent=2, sort_keys=True, default=str))
    for account in terraform_json["accounts"][account_type]:
        # print(account)
        if account == AWS_ACCOUNT:
            # Create the new Account Specific Dictionary
            AWS_ACCOUNT_DICT = terraform_json["accounts"][account_type][account]
            AWS_ACCOUNT_DICT["account_type"] = (account_type)
            AWS_ACCOUNT_DICT["account_name"] = (account)

for key, value in AWS_ACCOUNT_DICT.items():
  for region in region_list:
    if region in key:
      for k,v in value.items():
        if "ram" in k:
          pass
        elif "tag" in k:
          pass
        elif "multus_subnet" in k:
          multus_subnets.append(v)
        elif "private_app_subnet" in k:
          private_app_subnets.append(v)
      AWS_ACCOUNT_DICT[region]["multus_subnets"] = (multus_subnets)
      AWS_ACCOUNT_DICT[region]["private_app_subnets"] = (private_app_subnets)

# Create a new file $ACCOUNT.json to be used by locals
with open(f'../specific_vendor.json', 'w') as f:
  json.dump(AWS_ACCOUNT_DICT, f, indent=2)

# Closing file
f.close()