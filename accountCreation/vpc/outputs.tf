############
# Outputs
############
output "vpc_id" {
  value = { for k, v in module.aws_vpcs : k => v.aws_vpc }
}

output "public_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.public_subnet_az_0 }
}

output "public_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.public_subnet_az_1 }
}

output "private_app_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.private_app_subnet_az_0 }
}

output "private_app_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.private_app_subnet_az_1 }
}

output "private_db_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.private_db_subnet_az_0 }
}

output "private_db_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.private_db_subnet_az_1 }
}

output "ram_public_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.ram_public_subnets_az_0 }
}

output "ram_public_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.ram_public_subnets_az_1 }
}

output "ram_private_app_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.ram_private_app_subnets_az_0 }
}

output "ram_private_app_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.ram_private_app_subnets_az_1 }
}

output "ram_private_db_subnet_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.ram_private_db_subnets_az_0 }
}

output "ram_private_db_subnet_az_1" {
  value = { for k, v in module.aws_vpcs : k => v.ram_private_db_subnets_az_1 }
}

############
# Multus Outputs
############
output "multus_subnet_01_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.multus_subnet_01_az_0 }
}

output "multus_subnet_02_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.multus_subnet_02_az_0 }
}

output "ram_multus_subnet_01_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.ram_multus_subnet_01_az_0 }
}

output "ram_multus_subnet_02_az_0" {
  value = { for k, v in module.aws_vpcs : k => v.ram_multus_subnet_02_az_0 }
}