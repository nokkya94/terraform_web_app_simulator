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
resource "aws_db_instance" "webapp" {
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "14.17"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
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
