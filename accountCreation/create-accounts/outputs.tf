output "account_arn" {
  value = values(module.aws_organizations_account)[*].account_arn
}

output "account_id" {
  value = values(module.aws_organizations_account)[*].account_id
}
