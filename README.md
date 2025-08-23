# Terraform Web App Simulator

## Case Study: Secure AWS Infrastructure as Code Pipeline

### 1. Executive Summary

This project provisions a secure, production-style AWS infrastructure for a web application using Terraform and GitHub Actions. The solution demonstrates modern cloud security practices such as automated CI/CD, Infrastructure as Code (IaC), and security scanning at multiple layers (SAST, SCA, DAST, secrets). It’s designed to simulate what an enterprise-grade secure pipeline looks like, but deployed on AWS Free Tier.

**Core Components:**

- **VPC:** Private + public subnets
- **ALB:** Fronts EC2 web instances
- **EC2:** Hosts the web app
- **RDS (Postgres/MySQL):** Encrypted, private subnet
- **S3:** For static assets + logs
- **WAF:** Protects ALB against common exploits
- **IAM Roles & Policies:** Least privilege
- **CloudWatch:** Monitoring + logs
- **Terraform Backend:** Remote state in S3, DynamoDB lock
- **CI/CD (GitHub Actions):** Plan, Apply, Security Scan → Deploy

**Visual Flow:**

User → ALB (WAF protected) → EC2 (App) → RDS (DB)
     ↘ Logs to S3 → CloudWatch → Alerts

CI/CD pipeline → Terraform → AWS Infrastructure
     ↘ Security Scanners (tfsec, Checkov, Trivy, Semgrep, Gitleaks, OWASP ZAP)

### 2. Security Controls Implemented

#### Infrastructure Hardening

- VPC isolation
- Security groups with least privilege
- RDS in private subnet with encryption enabled
- ALB with HTTPS + WAF

#### Pipeline Security

- Static Scans: tfsec, Checkov, Trivy, Semgrep
- Secrets Scans: Gitleaks
- Dynamic Scan: OWASP ZAP against deployed ALB

#### State Management

- Terraform remote backend with S3 + DynamoDB locking

#### CI/CD Governance

- Auto plan & apply on PR/merge
- Security scans block bad configs before deploy

### 3. Outcomes

✅ Fully automated pipeline: Push to main → infra deployed → scans executed.
✅ Security by default: Builds break on misconfigurations or secret leaks.
✅ Visibility: Logs + scans provide continuous feedback loop.

### 4. Lessons Learned

- **IaC Guardrails are critical:** Pipelines catch issues before they become cloud risks.
- **Security is continuous:** Static + dynamic analysis complement each other.
- **Cloud-native tools matter:** Using AWS-native state locking, logging, and monitoring avoids drift and improves resilience.

### 5. Future Improvements

- Multi-account deployment with AWS Organizations
- Centralized CloudTrail and VPC Flow Logs → Athena queries
- Open Policy Agent (OPA) for compliance-as-code (CIS/NIST)
- IAM Identity Center (SSO) for enterprise-ready auth

---

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
