resource "aws_ssm_parameter" "db_username" {
  name        = "/webapp/db/username"
  type        = "SecureString"
  value       = var.db_username
  key_id      = var.kms_key_id
  overwrite   = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/webapp/db/password"
  type        = "SecureString"
  value       = var.db_password
  key_id      = var.kms_key_id
  overwrite   = true

  tags = {
    Environment = var.environment
  }
}
