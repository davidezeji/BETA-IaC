# output "public_subnet_cidrs" {
#   value       = var.public_subnets
#   description = "Public subnet CIDRs"
# }

# output "private_subnet_cidrs" {
#   value       = var.private_subnets
#   description = "Private subnet CIDRs"
# }

# output "vpc_id" {
#   value       = var.vpc_id
#   description = "VPC ID"
# }

# output "vpc_cidr" {
#   value       = var.vpc_cidr
#   description = "VPC CIDR"
# }

# output "eks_cluster_security_group_id" {
#   description = "ID of the EKS cluster Security Group"
#   value       = module.eks_cluster.security_group_id
# }

# output "eks_cluster_security_group_arn" {
#   description = "ARN of the EKS cluster Security Group"
#   value       = module.eks_cluster.security_group_arn
# }

# output "eks_cluster_security_group_name" {
#   description = "Name of the EKS cluster Security Group"
#   value       = module.eks_cluster.security_group_name
# }

# output "eks_cluster_id" {
#   description = "The name of the cluster"
#   value       = module.eks_cluster.eks_cluster_id
# }

# output "eks_cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster"
#   value       = module.eks_cluster.eks_cluster_arn
# }

# output "eks_cluster_endpoint" {
#   description = "The endpoint for the Kubernetes API server"
#   value       = module.eks_cluster.eks_cluster_endpoint
# }

# output "eks_cluster_version" {
#   description = "The Kubernetes server version of the cluster"
#   value       = module.eks_cluster.eks_cluster_version
# }

# output "eks_cluster_identity_oidc_issuer" {
#   description = "The OIDC Identity issuer for the cluster"
#   value       = module.eks_cluster.eks_cluster_identity_oidc_issuer
# }

# output "eks_cluster_managed_security_group_id" {
#   description = "Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads"
#   value       = module.eks_cluster.eks_cluster_managed_security_group_id
# }

# output "eks_node_group_role_arn" {
#   description = "ARN of the worker nodes IAM role"
#   value       = module.eks_node_group.eks_node_group_role_arn
# }

# output "eks_node_group_role_name" {
#   description = "Name of the worker nodes IAM role"
#   value       = module.eks_node_group.eks_node_group_role_name
# }

# output "eks_node_group_id" {
#   description = "EKS Cluster name and EKS Node Group name separated by a colon"
#   value       = module.eks_node_group.eks_node_group_id
# }

# output "eks_node_group_arn" {
#   description = "Amazon Resource Name (ARN) of the EKS Node Group"
#   value       = module.eks_node_group.eks_node_group_arn
# }

# output "eks_node_group_resources" {
#   description = "List of objects containing information about underlying resources of the EKS Node Group"
#   value       = module.eks_node_group.eks_node_group_resources
# }

# output "eks_node_group_status" {
#   description = "Status of the EKS Node Group"
#   value       = module.eks_node_group.eks_node_group_status
# }

# # output "efs_1" {
# #   description = "EFS ID 1"
# #   value = module.eks_efs.0.id
# # }

# # output "efs_2" {
# #   description = "EFS ID 2"
# #   value = module.eks_efs.1.id
# # }
