# Files and Functions

## acct_config_setup.sh

- Configure Vault Token using $ACCOUNT. Each account has it's own plan/apply stages and the $ACCOUNT is a local variable set at the beginning of the stage. Token sets AWS Programmatic Access Keys with a TTL of 15 minutes. (Short-lived Credentials)
- Install necessary tools for the stage to run successfully. Essentially configuring the base Alpine Linux image to include jq, vault, aws cli, boto3, terraform, etc.
- *envsubst* configures the Terraform backend file to use a unique state file name that includes the account name.
- Currently there is a 30 second sleep timer which allows the PA keys time to properly set. This might be something we can remove/reduce after it's tested further.

## assignSubnetTags.py

- The script imports the variable $ACCOUNT and leverages boto3 to assign the 'name' tag to the subnets. This is a limitation of AWS Resource Sharing and this basically adds the tags after they're shared. **RAM Share per AWS Doc ["Link"](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-sharing.html) VPC tags and tags for the resources within the shared VPC are not shared with the participants.**
- Adding the tags is a one time action. This script is only run during the Terraform planning stage.
- This stage relies on it's parent pipeline that creates the VPC/Subnets. That stage adds the VPC/Subnet IDs into an artifact which the script uses to identify the IDs of resources shared to the $ACCOUNT.

## gitlab-backend.txt

- This is a template for the Gitlab state file. When *acct_config_setup.sh* runs it will configure the state file name to match the current account stage that's running. The output is 'config.gitlab.tfbackend'

## main.tf

- This currently is just creating a simple IAM Role with an attached Policy. This will be where account guardrails will be configured. i.e. CloudTrail, AWS Config, etc... Will add more to this section as we determine what's necessary for each BETA Environment.

## provider.tf

- Sets the Terraform plug-ins. Backend *http* is blank because the stage uses 'config.gitlab.tfbackend' during it's plan/apply process. This allows Terraform to set a unique state file name for each $ACCOUNT.

## terraform.auto.tfvars

- This is just setting the region to us-west-2

## variables.tf

- Declaring region variable that is set by terraform.auto.tfvars.
