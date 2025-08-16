variable "vpc_id" {
  type        = string
  description = "VPC ID where the security groups will be created"
}
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}
variable "rds_postgres_cidr_blocks" {
  description = "List of CIDR blocks for RDS PostgreSQL security group"
  type        = list(string)
}