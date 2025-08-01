variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
}

variable "kms_key_id" {
  description = "KMS Key ID or ARN for SSM parameter encryption"
  type        = string
}