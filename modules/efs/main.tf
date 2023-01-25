module "label" {
  source      = "../label/"
  enabled     = var.enabled
  namespace   = var.namespace
  name        = var.name
  stage       = var.stage
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

locals {
  dns_name = "${join("", aws_efs_file_system.default.*.id)}.efs.${var.region}.amazonaws.com"
}



resource "aws_efs_file_system" "default" {
  count                           = var.enabled ? 1 : 0
  tags                            = module.label.tags
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
}

resource "aws_efs_mount_target" "default" {
  count           = var.enabled && length(var.subnets) > 0 ? length(var.subnets) : 0
  file_system_id  = join("", aws_efs_file_system.default.*.id)
  ip_address      = var.mount_target_ip_address
  subnet_id       = var.subnets[count.index]
  security_groups = [join("", aws_security_group.efs.*.id)]
}

resource "aws_security_group" "efs" {
  count       = var.enabled ? 1 : 0
  name        = format("%s-efs", module.label.id)
  description = "EFS Security Group"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = module.label.tags
}

resource "aws_security_group_rule" "ingress" {
  count       = var.enabled ? 1 : 0
  type        = "ingress"
  from_port   = "2049" # NFS
  to_port     = "2049"
  protocol    = "tcp"
  cidr_blocks = var.allowed_cidr_blocks
  //source_security_group_id = var.security_groups[count.index]
  security_group_id = join("", aws_security_group.efs.*.id)
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.efs.*.id)
}

# module "dns" {
#   source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.5.0"
#   enabled = var.enabled && length(var.zone_id) > 0 ? true : false
#   name    = var.dns_name == "" ? module.label.id : var.dns_name
#   ttl     = 60
#   zone_id = var.zone_id
#   records = [local.dns_name]
# }

resource "aws_efs_access_point" "access_point" {

  file_system_id = join("", aws_efs_file_system.default.*.id)
  posix_user {
    gid = var.posix_user_gid
    uid = var.posix_user_uid
  }
  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_gid   = var.root_directory_owner_gid
      owner_uid   = var.root_directory_owner_uid
      permissions = var.root_directory_permissions
    }
  }
}