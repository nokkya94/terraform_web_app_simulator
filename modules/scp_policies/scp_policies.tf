# Deny Public S3 Buckets
resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3"
  description = "Prevent creation of publicly accessible S3 buckets"
  content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "s3:PutBucketAcl",
        "s3:PutBucketPolicy"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": ["public-read", "public-read-write"]
        }
      }
    }
  ]
}
EOT
}

# Require MFA for Console Access
resource "aws_organizations_policy" "require_mfa" {
  name        = "RequireMFA"
  description = "Deny console access if MFA is not present"
  content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
EOT
}

# Restrict Regions (Org Policy)
resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictRegions"
  description = "Deny resource creation outside approved regions"
  content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1","us-west-2"]
        }
      }
    }
  ]
}
EOT
}
