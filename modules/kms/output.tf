output "ssm_key_id" {
  value = aws_kms_key.ssm.id
}

output "ssm_key_arn" {
  value = aws_kms_key.ssm.arn
}

output "cloudwatch_logs_kms_key_arn" {
  value = aws_kms_key.cloudwatch_logs.arn
}