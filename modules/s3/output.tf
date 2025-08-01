output "s3_bucket_with_alb_logs" {
  value       = aws_s3_bucket.alb_logs_bucket.id
  description = "The S3 bucket for storing ALB logs"
}