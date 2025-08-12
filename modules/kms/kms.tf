#tfsec:ignore:aws-kms-auto-rotate-keys
resource "aws_kms_key" "ssm" {
  description             = "KMS key for SSM parameter encryption"
  deletion_window_in_days = 7

policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::370404697657:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "AllowEC2RoleToDecrypt",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::370404697657:role/WebAppEC2Role"
        },
        "Action": [
          "kms:Decrypt"
        ],
        "Resource": "*"
      }
    ]
  })

  tags = {
    Name = "ssm-parameter-kms-key"
  }
}
