locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    },
    {
      "k8s.io/cluster-autoscaler/enabled" = "${var.enable_cluster_autoscaler}"
    }
  )
  aws_policy_prefix = format("arn:%s:iam::aws:policy", join("", data.aws_partition.current.*.partition))
}

module "label" {
  source      = "../label/"
  namespace   = var.namespace
  stage       = var.stage
  environment = var.environment
  name        = var.name
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["workers"]))
  tags        = local.tags
  enabled     = var.enabled
}


data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "amazon_eks_worker_node_autoscaler_policy" {
  count = (var.enabled && var.enable_cluster_autoscaler) ? 1 : 0
  statement {
    sid = "AllowToScaleEKSNodeGroupAutoScalingGroup"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:AssignIpv6Addresses",
      "ec2:UnassignIpv6Addresses",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "amazon_eks_worker_node_autoscaler_policy" {
  count  = (var.enabled && var.enable_cluster_autoscaler) ? 1 : 0
  name   = "${module.label.id}-autoscaler"
  path   = "/"
  policy = join("", data.aws_iam_policy_document.amazon_eks_worker_node_autoscaler_policy.*.json)
}

resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.label.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.label.tags
}

resource "aws_iam_instance_profile" "myec2_profile" {
  //count              = var.enabled ? 1 : 0
  name = module.label.id
  role = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKSWorkerNodePolicy")
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_ssm_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonSSMManagedInstanceCore")
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_autoscaler_policy" {
  count      = (var.enabled && var.enable_cluster_autoscaler) ? 1 : 0
  policy_arn = join("", aws_iam_policy.amazon_eks_worker_node_autoscaler_policy.*.arn)
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEKS_CNI_Policy")
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonEC2ContainerRegistryReadOnly")
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_s3_full_access" {
  count      = var.enabled ? 1 : 0
  policy_arn = format("%s/%s", local.aws_policy_prefix, "AmazonS3FullAccess")
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "existing_policies_for_eks_workers_role" {
  count      = var.enabled ? var.existing_workers_role_policy_arns_count : 0
  policy_arn = var.existing_workers_role_policy_arns[count.index]
  role       = join("", aws_iam_role.default.*.name)
}

data "template_file" "user_data_hw" {
  template = <<EOF
        #!/bin/bash
        set -o xtrace
        echo ${var.cluster_name}
        /etc/eks/bootstrap.sh ${var.cluster_name} --kubelet-extra-args "--cpu-manager-policy=static --cpu-manager-reconcile-period=5s --system-reserved=cpu=512m,memory=512Mi --kube-reserved=cpu=512m,memory=512Mi"
        # echo "net.ipv4.conf.default.rp_filter = 0" | tee -a /etc/sysctl.conf
        # echo "net.ipv4.conf.all.rp_filter = 0" | tee -a /etc/sysctl.conf
        # sudo sysctl -p
        # sleep 45
        # ls /sys/class/net/ > /tmp/ethList;cat /tmp/ethList |while read line ; do sudo ifconfig $line up; done
        # grep eth /tmp/ethList |while read line ; do echo "ifconfig $line up" >> /etc/rc.d/rc.local; done
        # systemctl enable rc-local
        # chmod +x /etc/rc.d/rc.local
    EOF
}

resource "aws_launch_template" "eks_node_launch" {
  # count = var.enabled ? 1 : 0
  name = format("%s%s", module.label.id, "-template")
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten(tolist(lookup(block_device_mappings.value, "ebs", [])))
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }
  # dynamic "credit_specification" {
  #   for_each = var.credit_specification != null ? [var.credit_specification] : []
  #   content {
  #     cpu_credits = lookup(credit_specification.value, "cpu_credits", null)
  #   }
  # }
  # disable_api_termination = var.disable_api_termination
  ebs_optimized = var.ebs_optimized
  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications != null ? [var.elastic_gpu_specifications] : []
    content {
      type = lookup(elastic_gpu_specifications.value, "type", null)
    }
  }
  image_id      = var.image_id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.myec2_profile.name
  }
  key_name = var.key_name
  # dynamic "placement" {
  #   for_each = var.placement != null ? [var.placement] : []
  #   content {
  #     affinity          = lookup(placement.value, "affinity", null)
  #     availability_zone = lookup(placement.value, "availability_zone", null)
  #     group_name        = lookup(placement.value, "group_name", null)
  #     host_id           = lookup(placement.value, "host_id", null)
  #     tenancy           = lookup(placement.value, "tenancy", null)
  #   }
  # }
  user_data = base64encode(data.template_file.user_data_hw.rendered)

  monitoring {
    enabled = var.enable_monitoring
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  network_interfaces {
    description                 = module.label.id
    device_index                = 0
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.security_group_ids
  }
  tag_specifications {
    resource_type = "volume"
    tags          = module.label.tags
  }
  tag_specifications {
    resource_type = "instance"
    tags          = module.label.tags
  }
  tags = module.label.tags
  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_eks_node_group" "default" {
#   count           = var.enabled ? 1 : 0
#   cluster_name    = var.cluster_name
#   node_group_name = module.label.id
#   node_role_arn   = join("", aws_iam_role.default.*.arn)
#   subnet_ids      = var.subnet_ids
#   #ami_type        = var.ami_type
#   # disk_size       = var.disk_size
#   #instance_types  = var.instance_types
#   labels          = var.kubernetes_labels
#   release_version = var.ami_release_version
#   version         = var.kubernetes_version
#   tags = module.label.tags
#   scaling_config {
#     desired_size = var.desired_size
#     max_size     = var.max_size
#     min_size     = var.min_size
#   }
#   launch_template {
#     id = aws_launch_template.eks_node_launch.id
#     version = var.launch_template_version
#   }
#   # dynamic "remote_access" {
#   #   for_each = var.ec2_ssh_key != null && var.ec2_ssh_key != "" ? ["true"] : []
#   #   content {
#   #     ec2_ssh_key               = var.ec2_ssh_key
#   #     source_security_group_ids = var.source_security_group_ids
#   #   }
#   # }
#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_autoscaler_policy,
#     aws_iam_role_policy_attachment.amazon_eks_cni_policy,
#     aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
#     var.module_depends_on,
#     aws_lambda_function.instance_restart_fun
#   ]
#   lifecycle {
#     ignore_changes = [scaling_config[0].desired_size]
#   }
# }

resource "aws_autoscaling_group" "default" {
  #availability_zones = ["us-east-2b"]
  name                = "${var.namespace}-${var.stage}-${var.name}-asg"
  desired_capacity    = var.desired_size
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = ["${var.multus_nodes_subnet}"]

  launch_template {
    id      = aws_launch_template.eks_node_launch.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_autoscaler_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
    aws_lambda_function.instance_restart,
    var.module_depends_on
  ]

  # tags  {
  #     name = "NAME"
  #     value = "upf-outpost-terraform"
  #   }
}

resource "aws_autoscaling_lifecycle_hook" "asghook_launch_instance" {
  name                   = "asghook_launch_instance"
  autoscaling_group_name = "${var.namespace}-${var.stage}-${var.name}-asg"
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"

  depends_on = [aws_autoscaling_group.default]
}


resource "aws_autoscaling_lifecycle_hook" "asghook_terminate_instance" {
  name                   = "asghook_terminate_instance"
  autoscaling_group_name = "${var.namespace}-${var.stage}-${var.name}-asg"
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  depends_on             = [aws_autoscaling_group.default]
}


# resource "null_resource" "delete_default_lifecyclehooks_instances_restart" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       export AWS_REGION=${var.region}
#       echo "Executing delete default lifecyclehooks and terminating instances"
#       sleep 120
#       echo Asg name - "${module.label.id}"
#       aws autoscaling delete-lifecycle-hook --region "${var.region}" --lifecycle-hook-name Launch-LC-Hook --auto-scaling-group-name "${module.label.id}"
#       aws autoscaling delete-lifecycle-hook --region "${var.region}" --lifecycle-hook-name Terminate-LC-Hook --auto-scaling-group-name "${module.label.id}"
#       sleep 25
#       for ID in $(aws autoscaling describe-auto-scaling-groups --region "${var.region}" --auto-scaling-group-names "${module.label.id}" --query 'AutoScalingGroups[0].Instances[].InstanceId' --output text);do aws ec2 terminate-instances --region "${var.region}" --instance-ids $ID;done
#     EOT
#   }
#   depends_on = [ aws_autoscaling_group.default ]
# }

#######
# // Instance Restart Lamnda Fn2
# data "archive_file" "instance_restart" {
#     type = "zip"
#     source_dir = "${path.module}/lambda_functions/fn2"
#     output_path = "${path.module}/instance_restart.zip"
# }

# resource "aws_lambda_function" "instance_restart_fun" {
#     filename         = "${path.module}/instance_restart.zip"
#     function_name    = "instance_restart_fun"
#     role             = aws_iam_role.multus_lambda_execution_role.arn
#     #handler          = "instance_restart.lambda_handler"
#     handler = "index.handler"
#     source_code_hash = filebase64sha256(data.archive_file.instance_restart.output_path)
#     runtime          = "python3.7"
#     timeout          = "30"
#     tags = var.tags
# }


data "aws_lambda_invocation" "restart_lambda_invocation" {
  depends_on = [aws_autoscaling_group.default, aws_lambda_function.instance_restart]

  function_name = "instances_restart_in_asg"
  input         = <<JSON
  {
    "AsgName": "${aws_autoscaling_group.default.name}"
  }
  JSON
}