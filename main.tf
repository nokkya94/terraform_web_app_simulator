data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source                    = "./modules/network"
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = data.aws_availability_zones.available.names
  alb_security_group_id     = [module.securityg.webapp_alb_sg_id]
}

module "securityg" {
  source = "./modules/securityg"
  vpc_id = module.network.vpc_id
}

module "compute" {
  source                 = "./modules/compute"
  instance_count         = var.instance_count
  instance_type          = var.instance_type
  ami_id                 = data.aws_ssm_parameter.amazon_linux_2023.value
  subnet_id              = module.network.private_subnet_ids
  vpc_security_group_ids = [module.securityg.webapp_instance_sg_id]
  alb_dns_name           = module.network.alb_dns_name
}
