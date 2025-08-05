resource "aws_s3_bucket" "alb_logs_bucket" {
  bucket          = var.alb_logs_bucket_name
  force_destroy = true
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