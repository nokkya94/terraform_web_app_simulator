resource "aws_security_group" "webapp_alb_sg" {
  name        = "webapp_security_group"
  description = "Security group for the web application"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webapp_instance_sg" {
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
  security_groups = var.rds_postgres_cidr_blocks
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

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds_postgres_sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_postgres_sg"
  }
}