#tfsec:ignore:AWS002
#tfsec:ignore:AWS018
#tfsec:ignore:AWS019
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "alb_logs_bucket" {
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

#tfsec:ignore:AWS002
#tfsec:ignore:AWS018
#tfsec:ignore:AWS019
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "s3_with_config_logs" {
  bucket = "${var.environment}-config-logs-avertech0"
  force_destroy = true
}

# Block all public ACLs on the config bucket
resource "aws_s3_bucket_public_access_block" "s3_with_config_logs_block" {
  bucket = aws_s3_bucket.s3_with_config_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:AWS017
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_with_config_logs_encryption" {
  bucket = aws_s3_bucket.s3_with_config_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "config_logs" {
  bucket = aws_s3_bucket.s3_with_config_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSConfigPermissions",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.s3_with_config_logs.id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${aws_s3_bucket.s3_with_config_logs.id}"
      }
    ]
  })
}

#tfsec:ignore:AWS002
#tfsec:ignore:AWS018
#tfsec:ignore:AWS019
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "cloudtrail_logs" {
 bucket = "${var.environment}-cloudtrail-logs-avertech0"
 force_destroy = true
}

# Block all public ACLs on the bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_block" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:AWS017
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_encryption" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSCloudTrailLoggingPermissions",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.id}/*"
      }
    ]
  })
}

