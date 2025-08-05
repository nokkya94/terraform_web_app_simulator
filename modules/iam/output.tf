output "webapp_ec2_instance_profile" {
  value       = aws_iam_instance_profile.webapp_ec2_instance_profile.name
  description = "The name of the IAM instance profile for the web application EC2 instances"
}

output "bastion_instance_profile" {
  value       = aws_iam_instance_profile.bastion_profile.name
  description = "The name of the IAM instance profile for the bastion host"
}

output "rds_monitoring_role_arn" {
  value       = aws_iam_role.rds_monitoring.arn
  description = "The ARN of the IAM role for RDS enhanced monitoring"
}