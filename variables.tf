variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "VPC CIDR block must be in the format x.x.x.x/<some_network_prefix>"
  }
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)

}

# variable "backend_bucket_name" {
#   description = "The name of the S3 bucket for storing Terraform state files"
#   type        = string
# }
# variable "dynamodb_table_name" {
#   description = "The name of the DynamoDB table for state locking"
#   type        = string
#   validation {
#     condition     = can(regex("^[a-z0-9-]{3,63}$", var.dynamodb_table_name))
#     error_message = "DynamoDB table name must be lowercase and between 3 and 63 characters long."
#   }
# }

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
}
variable "instance_type" {
  description = "Instance type for the instances"
  type        = string
  default     = "t3.micro"
}
#### below are commented out variables that can be used for IAM user and role management for remote state management
# variable "iam_user_name" {
#   description = "IAM username that Terraform should grant access to"
#   type        = string
# }
# variable "iam_role_name" {
#   description = "IAM role name for Terraform operations"
#   type        = string
# }
variable "ssh_my_ip" {
  description = "Your IP address in CIDR notation for SSH access"
  type        = string
}

variable "webapp_instance_key_name" {
  description = "Key name for the web application instances"
  type        = string
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "value for the database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "value for the database password"
}

variable "environment" {
  type        = string
  description = "The environment for the deployment (e.g., dev, staging, prod)"
}

variable "s3_bucket_with_alb_logs" {
  type        = string
  description = "S3 bucket name for storing ALB logs"
}