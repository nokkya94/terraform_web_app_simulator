variable "vpc_id" {
  type        = string
  description = "VPC ID where the security groups will be created"
}

variable "ssh_my_ip" {
  type        = string
}
variable "rds_postgres_cidr_blocks" {
  description = "List of CIDR blocks for RDS PostgreSQL security group"
  type        = list(string)
}