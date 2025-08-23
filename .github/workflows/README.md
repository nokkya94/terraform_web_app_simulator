# Terraform Web App Simulator

This repository provisions a secure, production-style AWS infrastructure for a web application using Terraform and GitHub Actions. It includes automated CI/CD, security scanning, and best practices for state management.

## Features

- **Modular AWS Infrastructure**: VPC, subnets, security groups, EC2, RDS, S3, ALB, IAM, WAF, CloudWatch, and more.
- **Remote State Management**: S3 and DynamoDB for Terraform state and locking.
- **CI/CD with GitHub Actions**: Automated plan, apply, and security scanning on push and PRs.
- **Security & Compliance**: tfsec, Checkov, Trivy, Semgrep, and Gitleaks for static and secret scanning.
- **DAST**: OWASP ZAP runs against the deployed ALB endpoint.

## Getting Started

### Prerequisites

- AWS account with permissions to create and manage resources
- [Terraform](https://www.terraform.io/downloads.html) >= 1.8.5
- S3 bucket and DynamoDB table for remote state
- SSH key pair for EC2 access

### Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/nokkya94/terraform_web_app_simulator.git
   cd terraform_web_app_simulator
   ```

2. **Configure AWS Credentials:**

   - Store your AWS credentials as GitHub secrets:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`
   - Set other required secrets and variables in your repository settings:
     - `DB_PASSWORD`, `IAM_ROLE_NAME`, `IAM_USER_NAME`, etc.
     - Repository variables: `DB_USERNAME`, `ENVIRONMENT`, `S3_BUCKET_WITH_ALB_LOGS`, `WEBAPP_INSTANCE_KEY_NAME`, `BACKEND_STATE_BUCKET_NAME`, `DYNAMODB_STATE_TABLE_NAME`

3. **Prepare Remote State:**

   - Create an S3 bucket and DynamoDB table for state and locking.
   - Example S3 bucket: `my-terraform-state-bucket-7748123`
   - Example DynamoDB table: `terraform-lock-table-7748123` with primary key `LockID` (String).

4. **Configure SSH Key:**
   - Generate an SSH key pair if you don't have one:
     ```bash
     ssh-keygen -t rsa -b 4096 -f web_instance_key
     ```
   - Add the public key to GitHub secrets as `WEB_INSTANCE_KEY_PUB`.

### Usage

#### Local

```bash
terraform init
terraform plan
terraform apply
```

#### CI/CD

- On push or PR to `main`, GitHub Actions will:
  - Lint, validate, and plan Terraform changes
  - Apply changes automatically on `main`
  - Run security and DAST scans

### Security & Compliance

- **Static Analysis**: tfsec, Checkov, Trivy, Semgrep
- **Secret Scanning**: Gitleaks
- **Dynamic Analysis**: OWASP ZAP

### Outputs

- The ALB DNS name is output after apply and used for DAST scanning.

### Cleanup

To remove all resources, run:

```bash
terraform destroy
```

Or manually delete resources in the AWS Console and clear the S3 state file and DynamoDB lock.

---

## Best Practices & Notes

- Always use a remote backend for state to avoid drift and conflicts.
- Never commit secrets or state files to version control.
- Use GitHub Actions for consistent, automated deployments and security checks.
- Review plan output before applying changes, especially in production.

---

## License

MIT

---

## Author

Alexandru Tanasiev aka nokkya994
