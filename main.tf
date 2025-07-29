data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source                    = "./modules/network"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = data.aws_availability_zones.available.names
  alb_security_group_id     = [module.securityg.webapp_alb_sg_id]
}

module "securityg" {
  source = "./modules/securityg"
  vpc_id = module.network.vpc_id
  ssh_my_ip = var.ssh_my_ip
}

module "compute" {
  source                 = "./modules/compute"
  instance_count         = var.instance_count
  instance_type          = var.instance_type
  ami_id                 = data.aws_ssm_parameter.amazon_linux_2023.value
  subnet_ids              = module.network.public_subnet_ids
  vpc_security_group_ids = [module.securityg.webapp_instance_sg_id]
  alb_dns_name           = module.network.alb_dns_name
  webapp_instance_key_name = var.webapp_instance_key_name
  depends_on = [module.network]
}

module "bastion" {
  source       = "./modules/bastion"
  instance_type = var.instance_type
  ami_id       = data.aws_ssm_parameter.amazon_linux_2023.value
  vpc_id       = module.network.vpc_id
  subnet_id    = module.network.public_subnet_ids[0]
  bastion_security_group_ids = [module.securityg.bastion_sg_id]
  bastion_key_name = var.bastion_key_name
}

resource "aws_lb_target_group_attachment" "webapp_attachment" {
  for_each = { for idx, id in module.compute.instance_ids : idx => id }
  target_group_arn = module.network.alb_target_group_arn
  target_id        = each.value
  port             = 80
  depends_on = [module.compute]
}
