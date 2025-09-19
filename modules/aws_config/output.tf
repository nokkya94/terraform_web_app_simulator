output "config_recorder_name" {
  value       = aws_config_configuration_recorder.main.name
  description = "AWS Config recorder name."
}

output "delivery_channel_name" {
  value       = aws_config_delivery_channel.main.name
  description = "AWS Config delivery channel name."
}

output "service_linked_role_arn" {
  value       = aws_iam_service_linked_role.config.arn
  description = "Service-linked role ARN used by AWS Config."
}
