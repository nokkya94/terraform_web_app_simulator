resource "aws_config_configuration_recorder" "main_config_recorder" {
  name     = "main_config_recorder"
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported = true
  }
}

resource "aws_iam_role" "config_role" {
  name = "aws-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Inline policy for S3 access
resource "aws_iam_role_policy" "config_s3_access" {
  name = "aws-config-s3-access"
  role = aws_iam_role.config_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::dev-config-logs-avertech0",
          "arn:aws:s3:::dev-config-logs-avertech0/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSConfigServiceRolePolicy"
}

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
