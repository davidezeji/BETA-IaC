############
# Modify Variables using terraform.auto.tfvars
############
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-west-2a"]
}

##
variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
  default     = "na"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
  default     = "dev"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
  default     = "app"
}

variable "delimiter" {
  type        = string
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
  default     = "-"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "kubernetes_version" {
  type        = string
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
  default     = "1.21"
}

# variable "istio_version" {
#   type        = string
#   description = "Desired Istio version"
#  }

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "oidc_provider_enabled" {
  type        = bool
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using `kiam` or `kube2iam`. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
  default     = true
}

variable "local_exec_interpreter" {
  type        = list(string)
  description = "shell to use for local_exec"
  default     = ["/bin/sh", "-c"]
}

variable "disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided"
  default     = 20
}

variable "instance_types" {
  type        = list(string)
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
  default     = ["t3.medium"]
}

variable "instance_type" {
  type        = string
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
  default     = "t3.medium"
}


variable "kubernetes_labels" {
  type        = map(string)
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  default     = {}
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the AutoScaling Group"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "The minimum size of the AutoScaling Group"
  default     = 1
}

variable "vpc_id" {
  type        = string
  description = "VPC"
  default     = ""
}

variable "vpc_cidr" {
  type        = string
  description = "VPC Cidr"
  default     = "172.31.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of Private Subnets"
  default     = []
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = true
  description = "Whether to apply the ConfigMap to allow worker nodes to join the EKS cluster and allow additional users, accounts and roles to acces the cluster"
}

############
# Should pull in dynamically
############
variable "image_id" {
  type        = string
  description = "AMI for eks nodes"
  default     = "ami-043ae9e91af48f40a"
}

variable "efs_service_ac_name" {
  type        = string
  description = "EFS Service account name"
  default     = "efs-csi-controller-sa"
}

variable "posix_user_gid" {
  type        = string
  description = "Efs posix user gid"
  default     = "10011"
}

variable "posix_user_uid" {
  type        = string
  description = "Efs posix user uid"
  default     = "10011"
}

variable "root_directory_path" {
  type        = string
  description = "Efs root directory path"
  default     = "/"
}

variable "root_directory_owner_gid" {
  type        = string
  description = "Efs root directory owner gid"
  default     = "10011"
}

variable "root_directory_owner_uid" {
  type        = string
  description = "Efs root directory owner uid"
  default     = "10011"
}

variable "root_directory_permissions" {
  type        = string
  description = "Efs root directory permissions"
  default     = "0755"
}
############
# Commented out new
############
/* variable "key_name" {
  type        = string
  description = "The SSH key name that should be used for the instance"
  default     = ""
}

variable "multus_nodes_subnet" {
  type = string
} */

############
# Commented out previously
############
# variable "public_subnets" {
#   type        = list(string)
#   default     = [ "subnet-0a42e3c19089a5d8f" ,"subnet-0a42e3c19089a5d8f" ]
#   description = "List of public subnets"
# }

# variable "spirent_endpoint" {
#   type      = string
#   description = "Spirent endpoint"
#   default = "http://10.0.0.99:8080"
# }

# variable "posix_user_gid" {
#   type = string
#   description = "Efs posix user gid"
# }
# variable "posix_user_uid" {
#   type = string
#   description = "Efs posix user uid"
# }

# variable "root_directory_path" {
#   type = string
#   description = "Efs root directory path"
# }

# variable "root_directory_owner_gid" {
#   type = string
#   description = "Efs root directory owner gid"
# }
# variable "root_directory_owner_uid" {
#   type = string
#   description = "Efs root directory owner uid"
# }
# variable "root_directory_permissions" {
#   type = string
#   description = "Efs root directory permissions"
# }
# variable "eks_plugin_csv" {
#    default= []
#    type = list(object({
#     plugin  = string
#     version = string
#   }))
#    description = "CSV for the plugins installation"
# }

# variable "codecommit_branch" {
#   type      = string
#   description = "Code coomit branch"
# }
# # variable "helm_ecr_registry" {
# #   type      = string
# #   description = "Helm ECR registry"
# # }

# variable "codecommit_poll" {
#   type      = bool
#   description = "Codecommit polling"
# }

# variable "codecommit_repo" {
#   type      = string
#   description = "Code Commit ECR Repository"
# }
# variable "s3_isv_init" {
#   type = string 
#   description = "S3 location for ISV init code"
# }


##### For NLB



# variable "vpc_cidr_block" {
#   type        = string
#   description = "VPC CIDR block"
# }


# variable "internal" {
#   type        = bool
#   description = "A boolean flag to determine whether the NLB should be internal"
# }

# variable "tcp_enabled" {
#   type        = bool
#   description = "A boolean flag to enable/disable TCP listener"
# }

# variable "access_logs_enabled" {
#   type        = bool
#   description = "A boolean flag to enable/disable access_logs"
# }

# variable "access_logs_region" {
#   type        = string
#   description = "The region for the access_logs S3 bucket"
# }

# variable "cross_zone_load_balancing_enabled" {
#   type        = bool
#   description = "A boolean flag to enable/disable cross zone load balancing"
# }

# variable "ip_address_type" {
#   type        = string
#   description = "The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`."
# }

# variable "deletion_protection_enabled" {
#   type        = bool
#   description = "A boolean flag to enable/disable deletion protection for NLB"
# }

# variable "deregistration_delay" {
#   type        = number
#   description = "The amount of time to wait in seconds before changing the state of a deregistering target to unused"
# }

# variable "health_check_threshold" {
#   type        = number
#   description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
# }

# variable "health_check_protocol" {
#   type        = string
#   description = "The protocol to use for the health check request"
# }

# variable "health_check_interval" {
#   type        = number
#   description = "The duration in seconds in between health checks"
# }

# variable "target_group_port" {
#  type        = number
#  description = "The port for the default target group"
# }

# variable "target_group_target_type" {
#   type        = string
#   description = "The type (`instance`, `ip` or `lambda`) of targets that can be registered with the target group"
# }

# variable "s3_bucket" {
#   type = string 
#   description = "S3 bucket"
# }
# variable "s3_key" {
#   type = string 
#   description = "S3 key for IAN script "
# }
# variable "init_script" {
#   type = string 
#   description = "init script inside zipped key"
# }
# variable "init_script_params" {
#   type = string 
#   description = "init script inside zipped key"
# }

# variable "network_function" {
#   type        = string
# }

# variable "multus_subnet1" {
#    type        = string
# }

# variable "helm_install" {
#   type        = bool
#   default     = false
#   description = "Defines if Helm is installed"
# }

# variable "extra_permissions" {
#   type        = list
#   default     = []
#   description = "List of action strings which will be added to IAM service account permissions."
# }

# variable "helm_s3_bucket" {
#   type      = string
#   description = "S3 bucket where helm charts are uploaded"
#   default = "dummys36418-9881-1009"
# }

# variable "helm_chart_zip" {
#   type      = string
#   description = "Name of the zip file that contains app helm charts"
#   default = "dummyhip6418-9881-1009"
# }

# variable "es_endpoint" {
#   type      = string
#   description = "Elastic search endpoint"
#   default = "vpc-subbu-es-vpc-3fqnnnh7aqdrqlymmteqqgay5i.us-east-1.es.amazonaws.com"
# }