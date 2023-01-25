#!/bin/bash

# Install jq and vault
apk add -q vault
# Vault's address can be provided here or as CI/CD variable
export VAULT_ADDR=https://vault-cluster-public-vault-12e08048.30d50977.z1.hashicorp.cloud:8200/
# Authenticate and get token. Token expiry time and other properties can be configured
# when configuring JWT Auth - https://www.vaultproject.io/api-docs/auth/jwt#parameters-1
export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=gitlab-tf-role jwt=$CI_JOB_JWT)"
# Now use the VAULT_TOKEN to setup AWS Access
export OUTPUT=$(vault read -format=json aws/creds/gitlab-tf-role ttl=900)

# Install jq
apk add -q curl jq vault
# Install AWS CLI
apk add --no-cache aws-cli
# Install Terraform #Versions: https://pkgs.alpinelinux.org/packages?name=terraform&branch=v3.16&repo=&arch=x86_64&maintainer=
apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/v3.16/main
# Install envsubst command for replacing config files in system startup
apk add gettext
# Create config.gitlab.tfbackend with Gitlab CICD Variables
envsubst < gitlab-backend.txt > config.gitlab.tfbackend

# Give Vault 30 seconds for PA keys to properly replicate
sleep 30

export AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq '.data.access_key' -j)
export AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq '.data.secret_key' -j)
export AWS_DEFAULT_REGION=us-west-2
