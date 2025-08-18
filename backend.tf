terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-7748123"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table-7748123"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.dynamodb_state_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "TerraformLockTable"
  }
}
