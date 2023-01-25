# Files and Functions

## ekscluster(Folder)

- This folder contains the Terraform module to deploy EKS Resources

## gitlab-backend.txt

- This is a template for the Gitlab state file. When *acct_config_setup.sh* runs it will configure the state file name to match the current account stage that's running. The output is 'config.gitlab.tfbackend'

## vendorTrim.py

- Python will take the existing aws_accounts.json artifact and parse out the individual account information by using the $ACCOUNT variable.
- The $ACCOUNT value is set by the CI Stage. The CI Stage declares the account for each stage when accountVendorConfig.py is run. Each stage is created by looping through all accounts.
- The script generates a new dictionary of values for the account maintaining all relevant account details.
- The output generated is 'specific_vendor.json' and is used in the EKS deployment locals.
- The script generates new key/value pairs for multus_subnets and private_app_subnets

## vendor_config_setup.sh

- Configure Vault Token using $ACCOUNT. Each account has it's own plan/apply stages and the $ACCOUNT is a local variable set at the beginning of the stage. Token sets AWS Programmatic Access Keys with a TTL of 15 minutes. (Short-lived Credentials)
- Install necessary tools for the stage to run successfully. Essentially configuring the base Alpine Linux image to include jq, vault, aws cli, boto3, terraform, etc.
- *envsubst* configures the Terraform backend file to use a unique state file name that includes the account name.
- Python executes vendorTrim.py which is described above. Outputs specific_vendor.json
- Currently there is a 30 second sleep timer which allows the PA keys time to properly set. This might be something we can remove/reduce after it's tested further.
