output "s3_bucket_with_alb_logs" {
  value       = aws_s3_bucket.alb_logs_bucket.id
  description = "The S3 bucket for storing ALB logs"
}

output "s3_name_with_config_logs" {
  value       = aws_s3_bucket.s3_with_config_logs.bucket
  description = "The S3 bucket for storing config logs"
}