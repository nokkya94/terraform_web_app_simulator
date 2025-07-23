
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  validation {  
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "VPC CIDR block must be in the format x.x.x.x/<some_network_prefix>"
  }
}

variable "private_subnet_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.private_subnet_cidr_block))
    error_message = "Private subnet CIDR block must be in the format x.x.x.x/<some_network_prefix>"
  }
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "availability_zones" {
  type        = list(string)
  description = "availability zone for the resources"
}

variable "alb_security_group_id" {
  type = list(string)
  description = "Security group IDs for the Application Load Balancer"
}

