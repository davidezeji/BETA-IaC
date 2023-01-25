# Using locals to define accounts in JSON
locals {
  data = jsondecode(file("../../aws_accounts.json"))

  accounts = flatten([for account_type, value in local.data.accounts : [for account, details in value : {
    account       = account
    account_type  = account_type
    account_email = details.account_email
    ou_id         = details.ou_id
    owner_email   = details.owner_email
    ticket_number = details.ticket_number
    environment   = details.environment
  }]])

}

# Setup Data resource to pull in Vault IAM User used for CrossAccount Access
data "aws_iam_user" "vault_user" {
  user_name = var.vault_user_name
}

# Leverages Organization Module to create an account within defined AWS Org.
module "aws_organizations_account" {
  source = "../../modules/aws-organization"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_name  = each.key
  account_email = each.value["account_email"]
  ou_id         = each.value["ou_id"]
  owner_email   = each.value["owner_email"]
  account_type  = each.value["account_type"]
  ticket_number = each.value["ticket_number"]
}

############
# Create Inline Policy for Vault Root Account that allows assume role for each created account.
# This policy will assume role and have full admin rights. (Might want to revist this in the future)
############
resource "aws_iam_user_policy" "vault_policy" {
  for_each = {
    for account in local.accounts : account.account => account
  }

  name = each.key
  user = data.aws_iam_user.vault_user.user_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = ["arn:aws:iam::${module.aws_organizations_account[each.key].account_id}:role/vault_assume_role"]
      },
    ]
  })
}

/* resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = ["arn:aws:iam::${module.aws_organizations_account[each.key].account_id}:role/vault_assume_role"]
      },
    ]
  })
} */


############
# Create Individual Roles in Vault for each New Account 
############
resource "vault_aws_secret_backend_role" "role" {
  for_each = {
    for account in local.accounts : account.account => account
  }

  backend         = "aws/"
  name            = each.key
  credential_type = "assumed_role"
  role_arns       = ["arn:aws:iam::${module.aws_organizations_account[each.key].account_id}:role/vault_assume_role"]
}

