output "webapp_ec2_instance_profile" {
  value       = aws_iam_instance_profile.webapp_ec2_instance_profile.name
  description = "The name of the IAM instance profile for the web application EC2 instances"
}

output "bastion_instance_profile" {
  value       = aws_iam_instance_profile.bastion_profile.name
  description = "The name of the IAM instance profile for the bastion host"
  
}