output "instance_ids" {
  value = aws_instance.webapp_instance[*].id
}
