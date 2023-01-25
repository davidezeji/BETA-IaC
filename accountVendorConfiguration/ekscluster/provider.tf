# Configuration to store terraform state in S3 
terraform {
  backend "http" {}
  required_providers {
    aws = {
      # Declaring the source location/address where Terraform can download plugins
      source = "hashicorp/aws"
      # Declaring the version of aws provider as greater than 3.0
      version = "~> 3.3"
    }
    template   = "~> 2.0"
    null       = "~> 2.0"
    local      = "~> 1.3"
    kubernetes = "~> 1.11"
    tfe = {
      version = "~> 0.35.0"
    }
  }
}
###################
# Provider block without alias is 'default' provider
# https://www.terraform.io/docs/configuration/providers.html#alias-multiple-provider-instances
###################
provider "aws" {
  region = var.aws_region
}