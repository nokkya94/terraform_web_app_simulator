variable "s3_bucket_name" {
  description = "S3 bucket to store AWS Config snapshots and history."
  type        = string
}

variable "s3_key_prefix" {
  description = "Optional key prefix within the S3 bucket for AWS Config objects."
  type        = string
  default     = null
}

variable "recorder_name" {
  description = "Name of the configuration recorder."
  type        = string
  default     = "main_config_recorder"
}

variable "delivery_channel_name" {
  description = "Name of the delivery channel."
  type        = string
  default     = "main_config_channel"
}

variable "include_global_resource_types" {
  description = "Whether to include global resource types (e.g., IAM)."
  type        = bool
  default     = true
}

variable "delivery_frequency_hours" {
  description = "Optional delivery frequency in hours (mapped to AWS enums; left simple here)."
  type        = number
  default     = null
}

# Toggle each rule as needed
variable "enable_rule_s3_versioning" {
  description = "Enable the AWS-managed rule to enforce S3 bucket versioning."
  type        = bool
  default     = true
}

variable "enable_rule_s3_encryption" {
  description = "Enable the AWS-managed rule to enforce S3 bucket encryption."
  type        = bool
  default     = true
}

variable "enable_rule_root_mfa" {
  description = "Enable the AWS-managed rule to enforce root MFA."
  type        = bool
  default     = true
}
