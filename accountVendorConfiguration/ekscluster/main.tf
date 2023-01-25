############
# Leveraging Locals to pull in each account_type to create VPCs for each type
############
locals {
  data                       = jsondecode(file("../../specific_vendor.json"))
  eks_worker_ami_name_filter = "amazon-eks-node-${var.kubernetes_version}*"
}

module "label" {
  source     = "../../modules/label/"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["cluster"]))
  tags       = var.tags
}

module "aws_ekscluster" {
  source = "../../modules/ekscluster"

  name       = local.data[var.aws_region]["clustername"]
  aws_region = var.aws_region
  ## Networking ##
  vpc_id              = local.data[var.aws_region]["vpc_id"]
  allowed_cidr_blocks = [(local.data[var.aws_region]["vpc_cidr"])]
  subnet_ids          = local.data[var.aws_region]["private_app_subnets"]
  ## Cluster ##
  label              = "${local.data.account_name}-eksbeta1"
  namespace          = local.data.isvname
  stage              = local.data.environment
  kubernetes_version = local.data[var.aws_region]["ekscluster_version"]
  ## Default Settings ##
  oidc_provider_enabled                     = var.oidc_provider_enabled
  local_exec_interpreter                    = var.local_exec_interpreter
  cluster_log_retention_period              = var.cluster_log_retention_period
  kubernetes_config_map_ignore_role_changes = false
  ## Future ##
  # tags                                      = var.tags
  # attributes                                = var.attributes
  # map_additional_iam_roles                  = var.map_additional_iam_roles  
  # enabled_cluster_log_types                 = var.enabled_cluster_log_types
  ############  
}

data "null_data_source" "wait_for_cluster_and_kubernetes_configmap" {
  inputs = {
    cluster_name             = module.aws_ekscluster.eks_cluster_id
    kubernetes_config_map_id = module.aws_ekscluster.kubernetes_config_map_id
  }
}

module "multuslambdafunctions" {
  source    = "../../modules/multus-lambda"
  asg_name  = module.eks_node_group.asg_grp_name
  label     = module.eks_node_group.asg_grp_name
  vpc_id    = local.data[var.aws_region]["vpc_id"]
  vpc_cidrs = [(local.data[var.aws_region]["vpc_cidr"]), (local.data[var.aws_region]["secondary_cidr"])]
  # multus_subnets requires a string input of subnet ids containing no spaces.
  multus_subnets = join(",", local.data[var.aws_region]["multus_subnets"])
}

module "eks_node_group" {
  source    = "../../modules/eksnodes"
  namespace = local.data.isvname
  stage     = local.data.environment
  name      = local.data[var.aws_region]["clustername"]
  ## Networking ##
  subnet_ids = local.data[var.aws_region]["private_app_subnets"]
  ## Cluster ##
  cluster_name       = data.null_data_source.wait_for_cluster_and_kubernetes_configmap.outputs["cluster_name"]
  instance_types     = [local.data[var.aws_region]["eks_node_type"]]
  desired_size       = local.data[var.aws_region]["eks_node_desired"]
  min_size           = local.data[var.aws_region]["eks_node_min"]
  max_size           = local.data[var.aws_region]["eks_node_max"]
  disk_size          = local.data[var.aws_region]["eks_node_disksize"]
  instance_type      = local.data[var.aws_region]["eks_node_type"]
  security_group_ids = [module.aws_ekscluster.security_group_id]
  ## Questions/improvements ##
  # key_name = join("-", [local.data.isvname, local.data.environment])
  image_id = var.image_id
  ## Future ##
  # attributes   = var.attributes
  # tags         = var.tags
  multus_nodes_subnet = local.data[var.aws_region]["private_app_subnet_az_0"]
  # kubernetes_labels   = var.kubernetes_labels
}

module "eks_efs" {
  count                            = 1
  source                           = "../../modules/efs/"
  namespace                        = local.data.isvname
  stage                            = local.data.environment
  name                             = "${local.data.isvname}.${local.data.environment}.${count.index}"
  region                           = var.aws_region
  vpc_id                           = local.data[var.aws_region]["vpc_id"]
  allowed_cidr_blocks              = [(local.data[var.aws_region]["vpc_cidr"]), (local.data[var.aws_region]["secondary_cidr"])]
  subnets                          = local.data[var.aws_region]["private_app_subnets"]
  posix_user_gid                   = var.posix_user_gid
  posix_user_uid                   = var.posix_user_uid
  root_directory_path              = var.root_directory_path
  root_directory_owner_gid         = var.root_directory_owner_gid
  root_directory_owner_uid         = var.root_directory_owner_uid
  root_directory_permissions       = var.root_directory_permissions
  security_groups                  = [module.aws_ekscluster.security_group_id, module.aws_ekscluster.eks_cluster_managed_security_group_id]
  cluster_name                     = data.null_data_source.wait_for_cluster_and_kubernetes_configmap.outputs["cluster_name"]
  cluster_identity_oidc_issuer     = module.aws_ekscluster.eks_cluster_identity_oidc_issuer #https://oidc.eks.us-west-2.amazonaws.com/id/7A6FFC96695C4C17EC0B3DC8FD7585F9"
  cluster_identity_oidc_issuer_arn = format("arn:aws:iam::${local.data.account_id}:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/%s", element(split("/", module.aws_ekscluster.eks_cluster_identity_oidc_issuer), 4))
  service_account_name             = var.efs_service_ac_name
}

resource "null_resource" "boot-script" {
  provisioner "local-exec" {
    command = "sh ./eks-bootstrap/bootstrap.sh"
    # interpreter = ["bash", "-c"]
    environment = {
      efs_id               = module.eks_efs.0.efs_id
      efs_csi_iam_role_arn = module.eks_efs.0.efs_csi_driver_iam_role_arn
      service_account_name = var.efs_service_ac_name
      region               = var.aws_region
      cluster_name         = data.null_data_source.wait_for_cluster_and_kubernetes_configmap.outputs["cluster_name"]
    }
  }
}