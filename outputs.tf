output "webapp_alb_sg_id" {
  value       = module.securityg.webapp_alb_sg_id
  description = "The ID of the web application security group"
}
output "webapp_instance_sg_id" {
  value       = module.securityg.webapp_instance_sg_id
  description = "The ID of the web application instance security group"
}
output "vpc_id" {
  value       = module.network.vpc_id
  description = "The ID of the VPC"
}
output "alb_dns_name" {
  value       = module.network.alb_dns_name
  description = "The DNS name of the Application Load Balancer"
}