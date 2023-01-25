variable "label" {
  type    = string
  default = " "
}


variable "multus_subnets" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = " "
}

variable "vpc_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "asg_name" {
  type    = string
  default = " "
}
