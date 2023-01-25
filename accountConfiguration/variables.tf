############
# Modify Variables using terraform.auto.tfvars
############
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vault_user_name" {
  type    = string
  default = "vault-admin"
}
