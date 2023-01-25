resource "aws_cloudwatch_event_rule" "instance_launch_terminate_action" {
  name        = "upf_terraform_instance_launch_terminate_action"
  description = "upf terraform instance launch terminate action"

  event_pattern = <<EOF
    {
        "source": [
            "aws.autoscaling"
        ],
        "detail-type": [
            "EC2 Instance-launch Lifecycle Action",
            "EC2 Instance-terminate Lifecycle Action"
        ],
        "detail": {
            "AutoScalingGroupName": [
              "${var.asg_name}"
            ]
        }
    }
    EOF
}

resource "aws_cloudwatch_event_target" "restart_lambdafn" {
  rule      = aws_cloudwatch_event_rule.instance_launch_terminate_action.name
  target_id = "lambda"
  arn       = aws_lambda_function.attach_eni.arn
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action       = "lambda:InvokeFunction"
  #function_name = "${aws_lambda_function.lambda.function_name}"
  function_name = aws_lambda_function.attach_eni.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_launch_terminate_action.arn
}