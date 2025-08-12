#tfsec:ignore:AWS002
#tfsec:ignore:AWS018
#tfsec:ignore:AWS019
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "alb_logs_bucket" {#checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
#checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
#checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
#checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
#checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
#checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  bucket          = var.alb_logs_bucket_name
  force_destroy = true
}

# Block all public ACLs on the bucket
resource "aws_s3_bucket_public_access_block" "alb_logs_bucket_block" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:AWS017
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_bucket_encryption" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSALBLoggingPermissions",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.alb_logs_bucket.id}/*"
      }
    ]
  })
}