resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "webapp-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "WebApp DB subnet group"
  }
}

resource "aws_db_parameter_group" "webapp_postgres" {
  name        = "webapp-postgres-params"
  family      = "postgres14"
  description = "Custom parameter group for query logging"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "0"
  }
}

#tfsec:ignore:aws-rds-enable-performance-insights-encryption
#tfsec:ignore:aws-rds-specify-backup-retention
#tfsec:ignore:aws-rds-enable-deletion-protection
#checkov:skip=CKV_AWS_123: "Suppress RDS performance insights encryption requirement"
#checkov:skip=CKV_AWS_124: "Suppress RDS backup retention requirement"
#checkov:skip=CKV_AWS_293: "Ensure that AWS database instances have deletion protection enabled"
#checkov:skip=CKV_AWS_157: "Ensure that RDS instances have Multi-AZ enabled"
#checkov:skip=CKV2_AWS_69: "Ensure AWS RDS database instance configured with encryption in transit"
resource "aws_db_instance" "webapp" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14.13"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  iam_database_authentication_enabled = true
  db_name              = "webappdb"
  db_subnet_group_name = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible  = false
  skip_final_snapshot  = true
  auto_minor_version_upgrade = true
  storage_encrypted    = true
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  parameter_group_name = aws_db_parameter_group.webapp_postgres.name
  copy_tags_to_snapshot = true


 enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  monitoring_interval = 60 # Enables enhanced monitoring (interval in seconds)

  monitoring_role_arn = var.rds_monitoring_role_arn 

  tags = {
    Name = "WebApp PostgreSQL DB"
  }
}
