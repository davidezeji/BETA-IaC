output "efs_arn" {
  value       = join("", aws_efs_file_system.default.*.arn)
  description = "EFS ARN"
}

output "efs_access_point_id" {
  value       = join("", aws_efs_access_point.access_point.*.id)
  description = "EFS Access point ID"
}

output "efs_id" {
  value       = join("", aws_efs_file_system.default.*.id)
  description = "EFS ID"
}

# output "host" {
#   value       = module.dns.hostname
#   description = "Route53 DNS hostname for the EFS"
# }

# output "dns_name" {
#   value       = local.dns_name
#   description = "EFS DNS name"
# }

# output "mount_target_dns_names" {
#   value       = coalescelist(aws_efs_mount_target.default.*.dns_name, [""])
#   description = "List of EFS mount target DNS names"
# }

output "mount_target_ids" {
  value       = coalescelist(aws_efs_mount_target.default.*.id, [""])
  description = "List of EFS mount target IDs (one per Availability Zone)"
}

output "mount_target_ips" {
  value       = coalescelist(aws_efs_mount_target.default.*.ip_address, [""])
  description = "List of EFS mount target IPs (one per Availability Zone)"
}

output "network_interface_ids" {
  value       = coalescelist(aws_efs_mount_target.default.*.network_interface_id, [""])
  description = "List of mount target network interface IDs"
}

output "security_group_id" {
  value       = join("", aws_security_group.efs.*.id)
  description = "EFS Security Group ID"
}

output "security_group_arn" {
  value       = join("", aws_security_group.efs.*.arn)
  description = "EFS Security Group ARN"
}

output "security_group_name" {
  value       = join("", aws_security_group.efs.*.name)
  description = "EFS Security Group name"
}


output "efs_csi_driver_iam_role_arn" {
  value       = aws_iam_role.efs_csi_driver.0.arn
  description = "EFS CSI Driver IAM role arn"
}