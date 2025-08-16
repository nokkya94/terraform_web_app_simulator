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

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
}
variable "instance_type" {
  description = "Instance type for the instances"
  type        = string
  default     = "t3.micro"
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