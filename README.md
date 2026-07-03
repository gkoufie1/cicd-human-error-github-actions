# CI/CD Human Error Reduction Project

## Project Summary

This project demonstrates how GitHub Actions reduces human error during application deployments.

Manual deployments are risky because engineers can forget steps, deploy the wrong version, skip validation, or miss configuration changes. This project replaces that manual process with an automated CI/CD workflow.

## Business Problem

Manual deployments are unreliable. A production outage can happen when an engineer deploys version `v1.2` instead of `v1.3`, forgets to run tests, or skips the health check.

## Solution

Use GitHub Actions to automate the deployment process:

1. Checkout code
2. Install dependencies
3. Run tests
4. Run security scans
5. Build Docker image
6. Copy image to EC2
7. Deploy container
8. Validate health endpoint

## Business Value

- Consistent deployments
- Reduced outages
- Better reliability
- Improved customer trust
- Repeatable release process
- Stronger audit trail

## Architecture

```text
Developer Pushes Code
        ↓
GitHub Repository
        ↓
GitHub Actions Pipeline
        ↓
Tests + Security Scan + Docker Build
        ↓
AWS EC2 Deployment Server
        ↓
Docker Container on Port 8081
        ↓
Customer/User Browser
```

## Folder Structure

```text
.
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── test_app.py
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── README.md
└── .github/
    └── workflows/
        └── cicd.yml
```

## GitHub Secrets Required

Add these secrets in GitHub:

```text
EC2_HOST      = EC2 public IP from Terraform output
EC2_SSH_KEY   = private key content used to SSH into EC2
```

## Terraform Deployment

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## Application URL

After deployment, open:

```text
http://EC2_PUBLIC_IP:8081
```

## Health Check

```bash
curl http://EC2_PUBLIC_IP:8081/health
```

Expected response:

```json
{"status":"healthy","version":"1.3"}
```

## Interview Answer

I automated deployment processes using GitHub Actions to eliminate manual deployment errors. The pipeline checks out code, installs dependencies, runs tests, scans for vulnerabilities, builds a Docker image, deploys it to an AWS EC2 server, and validates the health endpoint. This reduced operational risk, improved release consistency, and helped prevent wrong-version or skipped-validation deployments.
