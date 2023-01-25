############
# Multus CIDR association to new VPC
############
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = var.secondary_cidr[0]
}

############
# Multus Subnet Creation
############
resource "aws_subnet" "multus_subnet_01_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[0]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 8, each.value)
  map_public_ip_on_launch = false
  tags = {
    Name = "multus-subnet-00-${each.key}"
  }
}

resource "aws_subnet" "multus_subnet_02_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[0]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 8, each.value + length(var.account_subnets))
  map_public_ip_on_launch = false
  tags = {
    Name = "multus-subnet-01-${each.key}"
  }
}

############
# Multus Route Table
############
resource "aws_route_table" "multus" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "multus-rt-${var.name}"
  }
}

############
# Multus Subnets RT Association
############
resource "aws_route_table_association" "rt_assoc_multus_subnet_01_az_0" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.multus_subnet_01_az_0[each.key].id
  route_table_id = aws_route_table.multus.id
}

resource "aws_route_table_association" "rt_assoc_multus_subnet_02_az_0" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.multus_subnet_02_az_0[each.key].id
  route_table_id = aws_route_table.multus.id
}

############
# Creating Multus RAM Resource Share
############
resource "aws_ram_resource_share" "multus_subnet_01_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "Multus01Subnet-RAM-${each.key}-az0"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "Multus01Subnet-RAM-${each.key}-az0"
  }
}

resource "aws_ram_resource_share" "multus_subnet_02_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "Multus02Subnet-RAM-${each.key}-az0"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "Multus02Subnet-RAM-${each.key}-az0"
  }
}

# Creating RAM Resource association
resource "aws_ram_resource_association" "multus_subnet_01_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.multus_subnet_01_az_0[each.key].arn
  resource_share_arn = aws_ram_resource_share.multus_subnet_01_az_0[each.key].arn
  depends_on         = [aws_ram_resource_share.multus_subnet_01_az_0]
}

resource "aws_ram_resource_association" "multus_subnet_02_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.multus_subnet_02_az_0[each.key].arn
  resource_share_arn = aws_ram_resource_share.multus_subnet_02_az_0[each.key].arn
  depends_on         = [aws_ram_resource_share.multus_subnet_02_az_0]
}