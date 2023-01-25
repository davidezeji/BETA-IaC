import json
import boto3
import os

# Each Account Configuration will have the $ACCOUNT variable set, this will pull that information
AWS_ACCOUNT=os.environ["ACCOUNT"]

region_list = ["us-west-1", "us-west-2", "us-east-1", "us-east-2"]

# Open accounts.json file
with open('../aws_accounts.json', 'r') as f:
  aws_accounts = json.load(f)

for account_type in aws_accounts["accounts"]:
    for account in aws_accounts["accounts"][account_type]:
      if AWS_ACCOUNT == account:
        for region in region_list:
          if region in aws_accounts["accounts"][account_type][account]:
            client = boto3.resource('ec2', region_name=region)
            for k,v in aws_accounts["accounts"][account_type][account][region].items():
              # Ignore keys with unnecessary tagging values
              if "tags" in k or "ram" in k or "cidr" in k:
                pass
              elif "vpc" in k:
                for tag_k, tag_v in aws_accounts["accounts"][account_type][account][region][f'{k}_tags'].items():
                  client.create_tags(Resources=[v], Tags=[{'Key': tag_k, 'Value': tag_v}])
              elif "subnet" in k:
                for tag_k, tag_v in aws_accounts["accounts"][account_type][account][region][f'{k}_tags'].items():
                  client.create_tags(Resources=[v], Tags=[{'Key': tag_k, 'Value': tag_v}])