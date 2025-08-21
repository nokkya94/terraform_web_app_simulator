# Current account info
data "aws_caller_identity" "current" {}

# Service-linked role for AWS Config (created automatically if not present)
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

# Config recorder (uses the service-linked role ARN)
resource "aws_config_configuration_recorder" "main_config_recorder" {
  name     = "main_config_recorder"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported = true
  }
}

# Delivery channel (stores Config data in S3 bucket)
resource "aws_config_delivery_channel" "main_config_channel" {
  name           = "main_config_channel"
  s3_bucket_name = var.s3_name_with_config_logs

  # Make sure recorder exists first
  depends_on = [aws_config_configuration_recorder.main_config_recorder]
}

# Example AWS-managed rule (checks if versioning is enabled on all buckets)
resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
}