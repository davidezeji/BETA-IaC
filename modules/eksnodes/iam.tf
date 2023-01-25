# //Lambda Role

# resource "aws_iam_role" "multus_lambda_execution_role" {
#     name = "multus-lambda-role"
#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

# //Lambda Policy

# resource "aws_iam_role_policy" "multus_lambda_execution_policy" {
#     name = "multus-lambda-policy"
#     role = aws_iam_role.multus_lambda_execution_role.id
#     policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents",
#         "ec2:CreateNetworkInterface",
#         "ec2:DescribeInstances",
#         "ec2:DetachNetworkInterface",
#         "ec2:ModifyNetworkInterfaceAttribute",
#         "autoscaling:CompleteLifecycleAction",
#         "ec2:DeleteTags",
#         "ec2:DescribeNetworkInterfaces",
#         "ec2:CreateTags",
#         "ec2:DeleteNetworkInterface",
#         "ec2:AttachNetworkInterface",
#         "autoscaling:DescribeAutoScalingGroups",
#         "ec2:TerminateInstances"
#       ],
#       "Resource": [ 
#         "*"
#        ]
#     }
#   ]
# }
# EOF
# }
