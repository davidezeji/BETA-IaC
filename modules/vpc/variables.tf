variable "name" {
  description = "Provided name used for name concatenation of resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block"
  type        = list(any)
}

variable "secondary_cidr" {
  description = "CIDR block"
  type        = list(any)
}

variable "account_subnets" {
  type = list(any)
}
