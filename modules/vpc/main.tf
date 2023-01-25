############
# VPC Creation
############
resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.cidr[0]
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.aws_vpc.id
}

# resource "aws_flow_log" "flow_logs" {
#   iam_role_arn    = "arn"   # <--- Needs IAM Role
#   log_destination = "log"   # <--- Needs Log Destination
#   traffic_type    = "ALL"
#   vpc_id = aws_vpc.aws_vpc.id
# }

# Get Region Available Zones
data "aws_availability_zones" "az_availables" {
  state = "available"
}

############
# Subnet Creation
############
# https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
# Public Subnets
resource "aws_subnet" "public_subnet_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[0]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value)
  map_public_ip_on_launch = false
  tags = {
    Name = "public-subnet-00-${each.key}"
  }
}

resource "aws_subnet" "public_subnet_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[1]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value + length(var.account_subnets))
  map_public_ip_on_launch = false
  tags = {
    Name = "public-subnet-01-${each.key}"
  }
}


# Private Subnets
resource "aws_subnet" "private_app_subnet_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[0]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value + "${length(var.account_subnets) * 2}")
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-app-00-${each.key}"
  }
}

resource "aws_subnet" "private_app_subnet_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[1]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value + "${length(var.account_subnets) * 3}")
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-app-01-${each.key}"
  }
}

resource "aws_subnet" "private_db_subnet_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[0]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value + "${length(var.account_subnets) * 4}")
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-db-00-${each.key}"
  }
}

resource "aws_subnet" "private_db_subnet_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  availability_zone       = data.aws_availability_zones.az_availables.names[1]
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.aws_vpc.cidr_block, 8, each.value + "${length(var.account_subnets) * 5}")
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-db-01-${each.key}"
  }
}

############
# Internet Gateway
############
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name = "igw_${var.name}"
  }
}

############
# Routing
############
# Create Default Route Public Table
resource "aws_default_route_table" "rt_public" {
  default_route_table_id = aws_vpc.aws_vpc.default_route_table_id

  # Internet Route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-${var.name}"
  }
}

# Create EIP
resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = "eip-${var.name}"
  }
}

# Attach EIP to Nat Gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_az_0[var.account_subnets[0]].id
  tags = {
    Name = "nat-${var.name}"
  }
}

# Create Private Route Private Table
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.aws_vpc.id

  # Internet Route
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-rt-${var.name}"
  }
}

############
# Subnet Associations
############
# Public App Subnets Association
resource "aws_route_table_association" "rt_assoc_public_subnet_az_0" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.public_subnet_az_0[each.key].id
  route_table_id = aws_default_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_assoc_public_subnet_az_1" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.public_subnet_az_1[each.key].id
  route_table_id = aws_default_route_table.rt_public.id
}

# Private App Subnets Association
resource "aws_route_table_association" "rt_assoc_priv_subnets_app_0" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.private_app_subnet_az_0[each.key].id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rt_assoc_priv_subnets_app_1" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.private_app_subnet_az_1[each.key].id
  route_table_id = aws_route_table.rt_private.id
}

# Private DB Subnets Association
resource "aws_route_table_association" "rt_assoc_priv_subnets_db_0" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.private_db_subnet_az_0[each.key].id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rt_assoc_priv_subnets_db_1" {
  for_each = {
    for idx, subnet in var.account_subnets : subnet => idx
  }

  subnet_id      = aws_subnet.private_db_subnet_az_1[each.key].id
  route_table_id = aws_route_table.rt_private.id
}


############
# RAM: public_subnets
############
# Creating RAM Resource Share
resource "aws_ram_resource_share" "public_subnets_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PublicSubnet-RAM-${each.key}-az0"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PublicSubnet-RAM-${each.key}-az0"
  }
}

resource "aws_ram_resource_share" "public_subnets_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PublicSubnet-RAM-${each.key}-az1"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PublicSubnet-RAM-${each.key}-az1"
  }
}

# Creating RAM Resource association
resource "aws_ram_resource_association" "public_subnets_associate_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.public_subnet_az_0[each.key].arn
  resource_share_arn = aws_ram_resource_share.public_subnets_az_0[each.key].arn
  depends_on         = [aws_ram_resource_share.public_subnets_az_0]
}

resource "aws_ram_resource_association" "public_subnets_associate_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.public_subnet_az_1[each.key].arn
  resource_share_arn = aws_ram_resource_share.public_subnets_az_1[each.key].arn
  depends_on         = [aws_ram_resource_share.public_subnets_az_1]
}

############
# RAM: private_app_subnets
############
# Creating RAM Resource Share
resource "aws_ram_resource_share" "private_app_subnet_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PrivateAppSubnet-RAM-${each.key}-az0"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PrivateAppSubnet-RAM-${each.key}-az0"
  }
}

resource "aws_ram_resource_share" "private_app_subnet_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PrivateAppSubnet-RAM-${each.key}-az1"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PrivateAppSubnet-RAM-${each.key}-az1"
  }
}

# Creating RAM Resource association
resource "aws_ram_resource_association" "private_app_subnets_associate_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.private_app_subnet_az_0[each.key].arn
  resource_share_arn = aws_ram_resource_share.private_app_subnet_az_0[each.key].arn
  depends_on         = [aws_ram_resource_share.private_app_subnet_az_0]
}

resource "aws_ram_resource_association" "private_app_subnets_associate_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.private_app_subnet_az_1[each.key].arn
  resource_share_arn = aws_ram_resource_share.private_app_subnet_az_1[each.key].arn
  depends_on         = [aws_ram_resource_share.private_app_subnet_az_1]
}

############
# RAM: private_db_subnets
############
# Creating RAM Resource Share
resource "aws_ram_resource_share" "private_db_subnet_az_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PrivateDBSubnet-RAM-${each.key}-az0"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PrivateDBSubnet-RAM-${each.key}-az0"
  }
}

resource "aws_ram_resource_share" "private_db_subnet_az_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }

  name = "PrivateDBSubnet-RAM-${each.key}-az1"
  # Indicates whether principals outside your organization 
  # can be associated with a resource share.
  allow_external_principals = false

  tags = {
    Name = "PrivateDBSubnet-RAM-${each.key}-az1"
  }
}

# Creating RAM Resource association
resource "aws_ram_resource_association" "private_db_subnets_associate_0" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.private_db_subnet_az_0[each.key].arn
  resource_share_arn = aws_ram_resource_share.private_db_subnet_az_0[each.key].arn
  depends_on         = [aws_ram_resource_share.private_db_subnet_az_0]
}

resource "aws_ram_resource_association" "private_db_subnets_associate_1" {
  for_each = {
    for idx, account in var.account_subnets : account => idx
  }
  resource_arn       = aws_subnet.private_db_subnet_az_1[each.key].arn
  resource_share_arn = aws_ram_resource_share.private_db_subnet_az_1[each.key].arn
  depends_on         = [aws_ram_resource_share.private_db_subnet_az_1]
}
