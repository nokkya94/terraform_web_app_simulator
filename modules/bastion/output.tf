output "bastion_instance_ip" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP address of the bastion instance"
}