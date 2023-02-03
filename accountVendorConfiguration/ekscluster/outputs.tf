output "aws_ekscluster" {
  description = "Status of the EKS Node Group"
  value       = module.aws_ekscluster
}

output "multuslambdafunctions" {
  description = "Multus Lambda"
  value       = module.multuslambdafunctions
}

output "eks_node_group" {
  description = "EKS Nodes"
  value       = module.eks_node_group
}

output "eks_efs" {
  description = "EFS module"
  value       = module.eks_efs
}