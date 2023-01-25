############
# Organization Data
############
data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

############
# Creates new AWS Account
############
resource "aws_organizations_account" "account" {
  name                       = var.account_name
  email                      = var.account_email
  parent_id                  = var.ou_id
  iam_user_access_to_billing = "DENY"
  role_name                  = "vault_assume_role"

  tags = {
    terraform_managed = true
    account_name      = var.account_name
    owner_email       = var.owner_email
    account_type      = var.account_type
    ticket_number     = var.ticket_number
  }

  # Organizations API provides no method for reading this information after account creation
  # Terraform cannot perform drift detection on its value and will always show a difference for a configured value
  lifecycle {
    ignore_changes = [role_name]
  }
}


############
# Example code to create OUs, currently code imports OU by ou_id
############
/* resource "aws_organizations_organizational_unit" "workload" {
  name      = "workload"
  parent_id = aws_organizations_organization.this.roots[0].id
}


resource "aws_organizations_organizational_unit" "dev" {
  name      = "dev"
  parent_id = aws_organizations_organizational_unit.workload.id

  depends_on = [
    aws_organizations_organizational_unit.workload
  ]
} */
