#checkov:skip=CKV2_AWS_12: "Ensure the default security group of every VPC restricts all traffic"
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

#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "webapp_alb" {#checkov:skip=CKV2_AWS_20: "Ensure that ALB redirects HTTP requests into HTTPS ones"
  name = "webapp-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = var.alb_security_group_id
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  drop_invalid_header_fields = true
  enable_deletion_protection  = false

    access_logs {
    bucket  = var.alb_logs_bucket_name   # Define this variable or hardcode your bucket name
    enabled = true
    prefix  = "alb-logs"
  }

}

#checkov:skip=CKV_AWS_378: "Ensure AWS Load Balancer doesn't use HTTP protocol"
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

#tfsec:ignore:aws-elb-http-not-used
resource "aws_lb_listener" "webapp_listener" {#checkov:skip=CKV_AWS_88: "Suppress public IP warning for ALB"
#checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
#checkov:skip=CKV_AWS_2: "Ensure ALB protocol is HTTPS"
#checkov:skip=CKV_AWS_103: "Ensure that load balancer is using at least TLS 1.2"
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

#tfsec:ignore:AWS089
#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {#checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
#checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
  name              = "/aws/vpc/flowlogs/${aws_vpc.main_vpc.id}"
  retention_in_days = 30
}

resource "aws_flow_log" "main_vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main_vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = aws_cloudwatch_log_group.vpc_flow_logs.arn
    }]
  })
}