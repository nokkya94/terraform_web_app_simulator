
resource "aws_instance" "webapp_instance" {
  count             = var.instance_count
  ami               = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = var.subnet_ids[count.index]
  key_name          = aws_key_pair.webapp_instance_key.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  associate_public_ip_address = true
  ebs_optimized     = true
  iam_instance_profile = var.ec2_iam_instance_profile_name


  tags = {
    Name = "WebAppInstance-${count.index}"
  }
  
  user_data = templatefile("${path.module}/user_data.sh", {
    rds_endpoint = var.rds_endpoint
    DB_USER      = var.db_username
    DB_PASS  = var.db_password
  })
  
  metadata_options {
    http_tokens   = "required"   # Forces use of IMDSv2
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_key_pair" "webapp_instance_key" {
  key_name   = var.webapp_instance_key_name
  public_key = file("${path.root}/keys/web_instance_key.pub")
}