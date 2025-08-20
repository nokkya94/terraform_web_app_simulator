data "aws_caller_identity" "current" {}

# Config recorder (uses AWS-managed service-linked role)
resource "aws_config_configuration_recorder" "main_config_recorder" {
  name     = "main_config_recorder"

  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"

  recording_group {
    all_supported = true
  }
}

# Delivery channel (needs bucket you supply)
resource "aws_config_delivery_channel" "main_config_channel" {
  name           = "main_config_channel"
  s3_bucket_name = var.s3_name_with_config_logs
  depends_on     = [aws_config_configuration_recorder.main_config_recorder]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
}