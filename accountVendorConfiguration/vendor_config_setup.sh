#!/bin/bash

# Install jq and vault
apk add -q vault
# Vault's address can be provided here or as CI/CD variable
export VAULT_ADDR=https://vault-cluster-public-vault-12e08048.30d50977.z1.hashicorp.cloud:8200/
# Authenticate and get token. Token expiry time and other properties can be configured
# when configuring JWT Auth - https://www.vaultproject.io/api-docs/auth/jwt#parameters-1
export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=gitlab-tf-role jwt=$CI_JOB_JWT)"
# Now use the VAULT_TOKEN to setup AWS Access
export OUTPUT=$(vault read -format=json aws/creds/$ACCOUNT ttl=1800)

# Install jq
apk add -q curl jq sudo
# Install AWS CLI
apk add --no-cache aws-cli
# Install Terraform #Versions: https://pkgs.alpinelinux.org/packages?name=terraform&branch=v3.16&repo=&arch=x86_64&maintainer=
apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/v3.16/main
# Install envsubst command for replacing config files in system startup
apk add gettext

# Install Python and trim aws_accounts.json to only include $ACCOUNT Info
apk add -q curl jq python3 py3-pip
pip3 install --upgrade boto3
pip3 install gcip
# This script will remove all other accounts from the primary aws_accounts.json file
# and create a new file $ACCOUNT.json which will be referenced by terraform as locals.
python3 vendorTrim.py

# Create config.gitlab.tfbackend with Gitlab CICD Variables
envsubst < gitlab-backend.txt > config.gitlab.tfbackend

# Give Vault 30 seconds for PA keys to properly replicate
sleep 30

export AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq '.data.access_key' -j)
export AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq '.data.secret_key' -j)
export AWS_SESSION_TOKEN=$(echo $OUTPUT | jq '.data.security_token' -j)
export AWS_DEFAULT_REGION=us-west-2

# # No longer work with new JSON : JQ References
# # Create Bash Variables
# export VPC=$(echo $(jq -r '.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .vpc_id' ../aws_accounts.json))
# export PUBLIC_SUBNETS=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .public_subnet_az_0 + "", "" + .public_subnet_az_1]' ../aws_accounts.json))
# export PUBLIC_SUBNET01=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .public_subnet_az_0]' ../aws_accounts.json))
# export PUBLIC_SUBNET02=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .public_subnet_az_1]' ../aws_accounts.json))
# export APP_SUBNETS=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_app_subnet_az_0 + "", "" + .private_app_subnet_az_1]' ../aws_accounts.json))
# export APP_SUBNET01=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_app_subnet_az_0]' ../aws_accounts.json))
# export APP_SUBNET02=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_app_subnet_az_1]' ../aws_accounts.json))
# export DB_SUBNETS=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_db_subnet_az_0 + "", "" + .private_db_subnet_az_1]' ../aws_accounts.json))
# export DB_SUBNET01=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_db_subnet_az_0]' ../aws_accounts.json))
# export DB_SUBNET02=$(echo $(jq -r '[.accounts[] | select(.account_name=='\"$ACCOUNT\"') | .private_db_subnet_az_1]' ../aws_accounts.json))



