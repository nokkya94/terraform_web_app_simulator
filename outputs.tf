output "webapp_alb_sg_id" {
  value = module.securityg.webapp_alb_sg_id
}
output "webapp_instance_sg_id" {
  value = module.securityg.webapp_instance_sg_id
}
output "vpc_id" {
  value = module.network.vpc_id
}
output "alb_dns_name" {
  value = module.network.alb_dns_name
}