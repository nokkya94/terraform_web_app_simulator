resource "aws_s3_bucket" "alb_logs_bucket" {
  bucket          = var.alb_logs_bucket_name
}