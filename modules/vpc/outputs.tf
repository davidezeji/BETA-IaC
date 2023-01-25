output "aws_vpc" {
  value = aws_vpc.aws_vpc.*
}

output "public_subnet_az_0" {
  value = aws_subnet.public_subnet_az_0.*
}

output "public_subnet_az_1" {
  value = aws_subnet.public_subnet_az_1.*
}

output "private_app_subnet_az_0" {
  value = aws_subnet.private_app_subnet_az_0.*
}

output "private_app_subnet_az_1" {
  value = aws_subnet.private_app_subnet_az_1.*
}

output "private_db_subnet_az_0" {
  value = aws_subnet.private_db_subnet_az_0.*
}

output "private_db_subnet_az_1" {
  value = aws_subnet.private_db_subnet_az_1.*
}

output "ram_public_subnets_az_0" {
  value = aws_ram_resource_share.public_subnets_az_0.*
}

output "ram_private_app_subnets_az_0" {
  value = aws_ram_resource_share.private_app_subnet_az_0.*
}

output "ram_private_db_subnets_az_0" {
  value = aws_ram_resource_share.private_db_subnet_az_0.*
}

output "ram_public_subnets_az_1" {
  value = aws_ram_resource_share.public_subnets_az_1.*
}

output "ram_private_app_subnets_az_1" {
  value = aws_ram_resource_share.private_app_subnet_az_1.*
}

output "ram_private_db_subnets_az_1" {
  value = aws_ram_resource_share.private_db_subnet_az_1.*
}

############
# Multus
############
output "multus_subnet_01_az_0" {
  value = aws_subnet.multus_subnet_01_az_0.*
}

output "multus_subnet_02_az_0" {
  value = aws_subnet.multus_subnet_02_az_0.*
}

output "ram_multus_subnet_01_az_0" {
  value = aws_ram_resource_share.multus_subnet_01_az_0.*
}

output "ram_multus_subnet_02_az_0" {
  value = aws_ram_resource_share.multus_subnet_02_az_0.*
}