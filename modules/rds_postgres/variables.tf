variable "subnet_ids" {
  type = list(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_sg_id" {
  type = string
}

variable "rds_monitoring_role_arn" {
  type        = string
  description = "ARN of the IAM role for RDS enhanced monitoring"
}