# Account_email must be unique to each aws account
variable "account_email" {
  type    = string
  default = "dish_account@dish.com"
}

variable "ou_id" {
  type    = string
  default = "ou-example-0001"
}

variable "account_type" {
  type    = string
  default = "Dev"
}

variable "account_name" {
  type    = string
  default = "desired_account_name"
}

variable "ticket_number" {
  type    = string
  default = "abc_123"
}

variable "owner_email" {
  type    = string
  default = "dish_owner@dish.com"
}


