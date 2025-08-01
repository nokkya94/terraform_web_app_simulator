resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM parameter encryption"
  deletion_window_in_days = 7

  tags = {
    Name = "ssm-parameter-kms-key"
  }
}
