#tfsec:ignore:aws-ec2-no-public-ingress-sgr
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "webapp_alb_sg" {#checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
#checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
#checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource, this is a false positive,can’t see cross-module references properly."
  name        = "webapp_security_group"
  description = "Security group for the web application"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "webapp_instance_sg" {#checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource, this is a false positive,can’t see cross-module references properly."
  name        = "webapp_instance_security_group"
  description = "Security group for the web application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_alb_sg.id]
  }

   egress {
  description = "Allow outbound HTTPS for updates"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  description = "Allow outbound HTTP for updates"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  description = "Allow outbound PostgreSQL to RDS"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = var.rds_postgres_cidr_blocks
}
}

resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  description = "Allow SSH from Bastion to WebApp Instances"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webapp_instance_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

#checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource, this is a false positive,can’t see cross-module references properly."
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = "bastion-sg"
  }
}

#checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource, this is a false positive,can’t see cross-module references properly."
resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds_postgres_sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL from webapp instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_instance_sg.id]
  }

  egress {
    description = "Allow outbound traffic to VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = "rds_postgres_sg"
  }
}