output "key_id" {
  value = aws_kms_key.ssm.id
}

output "key_arn" {
  value = aws_kms_key.ssm.arn
}