variable "alb_logs_bucket_name" {
  description = "Name of the S3 bucket for ALB logs"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g. dev, test, prod)"
  type        = string
}