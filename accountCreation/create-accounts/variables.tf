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

variable "az_vpc_name" {
  type    = string
  default = "az"
}

variable "az_cidr" {
  type    = list(any)
  default = ["172.0.0.0/16"]
}

variable "az_subnets_per_tier" {
  type    = number
  default = 2
}

variable "lz_vpc_name" {
  type    = string
  default = "lz"
}

variable "lz_cidr" {
  type    = list(any)
  default = ["172.1.0.0/16"]
}

variable "lz_subnets_per_tier" {
  type    = number
  default = 2
}

/* variable "account_creation" {
  type = map(object({
    account_name  = string
    ou_id         = string
    account_email = string
    account_type  = string
    ticket_number = string
    owner_email   = string
  }))
  default = {
    "acct-test" = {
      account_name  = "account_name"
      account_email = "dish_account@dish.com"
      owner_email   = "dish_owner@dish.com"
      ou_id         = "ou_example_123"
      account_type  = "dev"
      ticket_number = "abc_123"
    }
  }
} */
