terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-7748123"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table-7748123"
    encrypt        = true
  }
}