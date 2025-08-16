#tfsec:ignore:aws-ec2-no-public-ingress-sgr
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "webapp_alb_sg" {
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
  cidr_blocks = var.rds_postgres_cidr_blocks
}
}

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