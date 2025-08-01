resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr_block
    tags = {
        Name = "MainVPC"
    }
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "PublicSubnet-${count.index}"  }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainInternetGateway"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_internet_gateway.id
    }
    tags = {
        Name = "MainRouteTable"
    }
}

resource "aws_route_table_association" "route_table_association" {
  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_lb" "webapp_alb" {
  name = "webapp-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = var.alb_security_group_id
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  drop_invalid_header_fields = true
  enable_deletion_protection  = true

    access_logs {
    bucket  = var.alb_logs_bucket_name   # Define this variable or hardcode your bucket name
    enabled = true
    prefix  = "alb-logs/"
  }

}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "WebAppTargetGroup"
  }
}

resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
  
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.private_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index}"
  }
}