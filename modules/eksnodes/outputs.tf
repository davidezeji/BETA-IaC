# output "eks_node_group_role_arn" {
#   description = "ARN of the worker nodes IAM role"
#   value       = join("", aws_iam_role.default.*.arn)
# }

# output "eks_node_group_role_name" {
#   description = "Name of the worker nodes IAM role"
#   value       = join("", aws_iam_role.default.*.name)
# }

# output "eks_node_group_id" {
#   description = "EKS Cluster name and EKS Node Group name separated by a colon"
#   value       = join("", aws_eks_node_group.default.*.id)
# }

# output "eks_node_group_arn" {
#   description = "Amazon Resource Name (ARN) of the EKS Node Group"
#   value       = join("", aws_eks_node_group.default.*.arn)
# }

# output "eks_node_group_resources" {
#   description = "List of objects containing information about underlying resources of the EKS Node Group"
#   value       = var.enabled ? aws_eks_node_group.default.*.resources : []
# }

# output "eks_node_group_status" {
#   description = "Status of the EKS Node Group"
#   value       = join("", aws_eks_node_group.default.*.status)
# }

# output "launch_template_id" {
#   description = "The ID of the launch template"
#   value       = join("", aws_launch_template.eks_node_launch.*.id)
# }

# output "launch_template_arn" {
#   description = "The ARN of the launch template"
#   value       = join("", aws_launch_template.eks_node_launch.*.arn)
# }

output "asg_grp_name" {
  description = "EKS Nodes ASG Name"
  value       = aws_autoscaling_group.default.name
}