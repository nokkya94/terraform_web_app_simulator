data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source                      = "./modules/network"
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  availability_zones          = data.aws_availability_zones.available.names
  alb_security_group_id       = [module.securityg.webapp_alb_sg_id]
  alb_logs_bucket_name        = module.s3.s3_bucket_with_alb_logs
  cloudwatch_logs_kms_key_arn = module.kms.cloudwatch_logs_kms_key_arn
}

module "kms" {
  source = "./modules/kms"
}

module "securityg" {
  source                   = "./modules/securityg"
  vpc_id                   = module.network.vpc_id
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
  kms_key_id  = module.kms.ssm_key_arn
}

module "s3" {
  source               = "./modules/s3"
  alb_logs_bucket_name = var.s3_bucket_with_alb_logs
  environment          = var.environment
}

resource "aws_wafv2_web_acl_association" "webapp_waf_assoc" {
  resource_arn = module.network.webapp_alb_arn
  web_acl_arn  = module.waf.web_acl_arn
}

module "waf" {
  source                      = "./modules/waf"
  region                      = var.aws_region
  cloudwatch_logs_kms_key_arn = module.kms.cloudwatch_logs_kms_key_arn
}

# commenting now as it incurs costs
# module "guardduty" {
#   source = "./modules/guardduty"
# }

module "aws_config" {
  source            = "./modules/aws_config"
  s3_bucket_name    = module.s3.s3_name_with_config_logs

  s3_key_prefix                = "aws-config/"
  include_global_resource_types = true
  delivery_frequency_hours     = 24  # snapshots daily

  enable_rule_s3_versioning = true
  enable_rule_s3_encryption = true
  enable_rule_root_mfa      = true

  depends_on        = [module.s3]
}

# commenting now as it incurs costs
# module "scp_policies" {
#   source = "./modules/scp_policies"
# }