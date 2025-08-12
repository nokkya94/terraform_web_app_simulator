data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source                     = "./modules/network"
  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = data.aws_availability_zones.available.names
  alb_security_group_id      = [module.securityg.webapp_alb_sg_id]
  alb_logs_bucket_name       = module.s3.s3_bucket_with_alb_logs
}

module "kms" {
  source = "./modules/kms"
}

module "securityg" {
  source                   = "./modules/securityg"
  vpc_id                   = module.network.vpc_id
  ssh_my_ip                = var.ssh_my_ip
  rds_postgres_cidr_blocks = var.private_subnet_cidr_blocks
  vpc_cidr_block           = var.vpc_cidr_block
}

module "iam" {
  source = "./modules/iam"
  region = var.aws_region
}

module "compute" {
  source                        = "./modules/compute"
  ec2_iam_instance_profile_name = module.iam.webapp_ec2_instance_profile
  instance_count                = var.instance_count
  instance_type                 = var.instance_type
  ami_id                        = data.aws_ssm_parameter.amazon_linux_2023.value
  subnet_ids                    = module.network.public_subnet_ids
  vpc_security_group_ids        = [module.securityg.webapp_instance_sg_id]
  alb_dns_name                  = module.network.alb_dns_name
  webapp_instance_key_name      = var.webapp_instance_key_name
  depends_on                    = [module.network]
  rds_endpoint                  = module.rds_postgres.rds_endpoint
  db_username                   = var.db_username
  db_password                   = var.db_password
}

module "bastion" {
  source                        = "./modules/bastion"
  ec2_iam_instance_profile_name = module.iam.bastion_instance_profile
  instance_type                 = var.instance_type
  ami_id                        = data.aws_ssm_parameter.amazon_linux_2023.value
  vpc_id                        = module.network.vpc_id
  subnet_id                     = module.network.public_subnet_ids[0]
  bastion_security_group_ids    = [module.securityg.bastion_sg_id]
  bastion_key_name              = var.bastion_key_name
}

resource "aws_lb_target_group_attachment" "webapp_attachment" {
  count            = var.instance_count
  target_group_arn = module.network.alb_target_group_arn
  target_id        = module.compute.instance_ids[count.index]
  port             = 80
  depends_on       = [module.compute]
}

module "rds_postgres" {
  source                  = "./modules/rds_postgres"
  subnet_ids              = module.network.private_subnet_ids
  db_username             = var.db_username
  db_password             = var.db_password
  db_sg_id                = module.securityg.rds_postgres_sg_id
  rds_monitoring_role_arn = module.iam.rds_monitoring_role_arn
}

module "aws_ssm_parameters" {
  source      = "./modules/ssm_parameters"
  db_username = var.db_username
  db_password = var.db_password
  environment = var.environment
  kms_key_id  = module.kms.key_id

}

module "s3" {
  source               = "./modules/s3"
  alb_logs_bucket_name = var.s3_bucket_with_alb_logs

}

resource "aws_wafv2_web_acl_association" "webapp_waf_assoc" {
  resource_arn = module.network.webapp_alb_arn
  web_acl_arn  = module.waf.web_acl_arn
}

module "waf" {
  source = "./modules/waf"
}

module "vpc_flow_logs" {
  source = "./modules/vpc_flow_logging"
  vpc_id = module.network.vpc_id
}