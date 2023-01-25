//Multus ENI Security Group
resource "aws_security_group" "lambda" {
  name        = "${var.label}-lambda"
  description = "Lambda multus"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.vpc_cidrs
  }

  tags = var.tags
}

// Attach ENI Lambda Fn1
data "archive_file" "attach_eni" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions"
  output_path = "attach_eni.zip"
}

resource "aws_lambda_function" "attach_eni" {
  filename         = "attach_eni.zip"
  function_name    = "attach_eni_${var.label}"
  role             = aws_iam_role.multus_lambda_execution_role.arn
  handler          = "attach_eni.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.attach_eni.output_path)
  runtime          = "python3.7"
  timeout          = "150"

  environment {
    variables = {
      SecGroupIds           = aws_security_group.lambda.id
      SubnetIds             = var.multus_subnets
      SourceDestCheckEnable = false
      useStaticIPs          = true
      ENITags               = "cnftype=poc,poccommon=true"

    }
  }

  tags = var.tags
}

