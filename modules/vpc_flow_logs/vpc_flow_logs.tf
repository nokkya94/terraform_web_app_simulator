resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 30
  kms_key_id        = var.cloudwatch_logs_kms_key_arn
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "vpc-flow-logs.amazonaws.com" },
      "Effect": "Allow",
      "Sid": ""
    }]
  })
}

resource "aws_flow_log" "vpc" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
}