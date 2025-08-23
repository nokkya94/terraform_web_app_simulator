variable "cloudwatch_logs_kms_key_arn" {
  description = "KMS key ARN for CloudWatch logs"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to enable flow logs for"
  type        = string
}