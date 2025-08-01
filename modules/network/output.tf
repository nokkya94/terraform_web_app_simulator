output "vpc_id" {
  value = aws_vpc.main_vpc.id
  description = "The ID of the VPC created by the network module"
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
  description = "The IDs of the public subnets created by the network module"
}
output "alb_dns_name" {
  value       = aws_lb.webapp_alb.dns_name
  description = "The DNS name of the ALB"
}
output "alb_target_group_arn" {
  value = aws_lb_target_group.webapp_tg.arn
}
output "webapp_alb_arn" {
  value = aws_lb.webapp_alb.arn
  description = "The ARN of the web application ALB"
}
output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}