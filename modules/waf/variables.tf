variable "region" {
  type        = string
  description = "The AWS region to deploy resources"
}

variable "cloudwatch_logs_kms_key_arn" {
  description = "KMS key ID for CloudWatch logs"
  type        = string
}