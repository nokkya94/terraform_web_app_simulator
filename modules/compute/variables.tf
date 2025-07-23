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

variable "subnet_id" {
  type = string
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
