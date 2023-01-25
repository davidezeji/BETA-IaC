############
# Leveraging Locals to pull in each account_type to create VPCs for each type
############
locals {
  # This allows Terraform access to the aws_accounts.json file as 'data'
  data = jsondecode(file("../../aws_accounts.json"))

  # Creates a list of account type
  account_types = [for k, v in local.data.accounts : k]
}

module "aws_vpcs" {
  source = "../../modules/vpc"
  # The for_each statement will create VPCs for each unique account_type in the local.data file
  for_each = { for x in local.account_types : x => x }

  name            = "${each.key}-vpc"
  cidr            = toset([for x in local.data.accounts["${each.key}"] : x[var.aws_region].vpc_cidr])
  secondary_cidr  = toset([for x in local.data.accounts["${each.key}"] : x[var.aws_region].secondary_cidr])
  account_subnets = [for k, v in local.data.accounts["${each.key}"] : k]
}
