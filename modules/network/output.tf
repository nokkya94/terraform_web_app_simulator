output "vpc_id" {
  value = aws_vpc.main_vpc.id
  description = "The ID of the VPC created by the network module"
}
output "private_subnet_ids" {
  value = aws_subnet.private_subnet.id
  description = "The ID of the private subnet created by the network module"
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
  description = "The IDs of the public subnets created by the network module"
}
output "alb_dns_name" {
  value       = aws_lb.webapp_alb.dns_name
  description = "The DNS name of the ALB"
}