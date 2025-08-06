variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
}
variable "instance_type" {
  description = "Instance type for the instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "alb_dns_name" {
  type = string
  description = "DNS name of the Application Load Balancer"
  validation {
    condition     = can(regex("^[a-z0-9.-]+\\.elb\\.amazonaws\\.com$", var.alb_dns_name))
    error_message = "ALB DNS name must be a valid AWS ELB DNS format."
  }
}

variable "webapp_instance_key_name" {
  type        = string
}

variable "ec2_iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Database username for RDS"
  type        = string
}

variable "db_password" {
  description = "Database password for RDS"
  type        = string
  sensitive   = true
}
