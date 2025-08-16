output "webapp_alb_sg_id" {
  value       = aws_security_group.webapp_alb_sg.id
  description = "The ID of the web application security group"
}

output "webapp_instance_sg_id" {
  value       = aws_security_group.webapp_instance_sg.id
  description = "The ID of the web application instance security group"
}

output "rds_postgres_sg_id" {
  value       = aws_security_group.rds_postgres_sg.id
  description = "The ID of the RDS PostgreSQL security group"
}