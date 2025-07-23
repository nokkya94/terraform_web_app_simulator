aws_region                = "us-east-1"
vpc_cidr_block            = "10.0.0.0/16"
private_subnet_cidr_block = "10.0.1.0/24"
public_subnet_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
backend_bucket_name       = "my-terraform-state-bucket-7748123"
dynamodb_table_name       = "terraform-lock-table-7748123"
terraform_iam_role_name  = "Whiz_User_222952.57585543"