#tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "bastion" {# checkov:skip=CKV_AWS_126: "Suppress detailed monitoring requirement for bastion host"
# checkov:skip=CKV_AWS_8: "Suppress EBS encryption requirement for bastion host"
# checkov:skip=CKV_AWS_135: "Suppress EBS optimization requirement for bastion host"
# checkov:skip=CKV_AWS_88: "Suppress public IP warning for bastion host"
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.bastion_key_name
  vpc_security_group_ids      = var.bastion_security_group_ids
  iam_instance_profile        = var.ec2_iam_instance_profile_name
  
  metadata_options {
    http_tokens = "required"       # Force IMDSv2
    http_endpoint = "enabled"      # Keep metadata endpoint on
  }

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = var.bastion_key_name
  public_key = file("${path.root}/keys/bastion_key.pub")
}


