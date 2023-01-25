resource "aws_iam_role" "multus_lambda_instance_restart_role" {
  name               = "multus-lambda-instance-restart-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

//Lambda Policy

resource "aws_iam_role_policy" "multus_instance_restart_lambda_policy" {
  name   = "multus-lambda-instance-restart-policy"
  role   = aws_iam_role.multus_lambda_instance_restart_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:TerminateInstances",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Resource": [ 
        "*"
       ]
    }
  ]
}
EOF
}


// Instance Restart Lamnda Fn2
data "archive_file" "instance_restart" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions"
  output_path = "instance_restart.zip"
}


resource "aws_lambda_function" "instance_restart" {
  filename         = "instance_restart.zip"
  function_name    = "instances_restart_in_asg"
  role             = aws_iam_role.multus_lambda_instance_restart_role.arn
  handler          = "auto_reboot.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.instance_restart.output_path)
  runtime          = "python3.7"
  timeout          = "150"
}
