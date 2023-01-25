# Using locals to define accounts in JSON
locals {
  data = jsondecode(file("../../aws_accounts.json"))

  accounts = flatten([for account_type, value in local.data.accounts : [for account, details in value : {
    account       = account
    account_id    = details.account_id
    account_type  = account_type
    account_email = details.account_email
    ou_id         = details.ou_id
    owner_email   = details.owner_email
    ticket_number = details.ticket_number
    environment   = details.environment
  }]])
}

module "ram_public_subnet_az_0" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_public_subnet_az_0"]
}

module "ram_public_subnet_az_1" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_public_subnet_az_1"]
}

module "ram_private_app_subnet_az_0" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_private_app_subnet_az_0"]
}

module "ram_private_app_subnet_az_1" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_private_app_subnet_az_1"]
}

module "ram_private_db_subnet_az_0" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_private_db_subnet_az_0"]
}

module "ram_private_db_subnet_az_1" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_private_db_subnet_az_1"]
}

############
# Multus
############
module "ram_multus_subnet_01_az_0" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_multus_subnet_01_az_0"]
}

module "ram_multus_subnet_02_az_0" {
  source = "../../modules/ram-principal"
  for_each = {
    for account in local.accounts : account.account => account
  }

  account_number     = each.value["account_id"]
  resource_share_arn = local.data.accounts[each.value["account_type"]][each.value["account"]][var.aws_region]["ram_multus_subnet_02_az_0"]
}