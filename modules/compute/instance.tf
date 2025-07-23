
resource "aws_instance" "webapp_instance" {
  count             = var.instance_count
  ami               = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  
  tags = {
    Name = "WebAppInstance-${count.index + 1}"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    alb_dns_name = var.alb_dns_name
  })
  
}