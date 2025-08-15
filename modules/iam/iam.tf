data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "ssm_parameter_access" {
  name        = "WebAppSSMParameterAccess"
  description = "Allow EC2 to read DB credentials from SSM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/webapp/db/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "webapp_ec2_role" {
  name = "WebAppEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "webapp_ec2_instance_profile" {
  name = "webapp-profile"
  role = aws_iam_role.webapp_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.webapp_ec2_role.name
  policy_arn = aws_iam_policy.ssm_parameter_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_attach" {
  role       = aws_iam_role.webapp_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}