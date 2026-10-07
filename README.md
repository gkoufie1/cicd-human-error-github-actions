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
7. Deploy to the inactive blue/green color and validate it on its own internal port
8. Promote (nginx config swap) and re-validate against the real public endpoint
9. Automatically roll back to the previous color if that last check fails

## Business Value

- Consistent deployments
- Reduced outages
- Better reliability
- Improved customer trust
- Repeatable release process
- Stronger audit trail
- Automatic rollback on a failed deployment — no manual intervention required
- Near-zero-downtime releases (a config reload, not a restart on the live port)

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
Deploy + validate on the INACTIVE color (blue/green, internal port only)
        ↓
Promote: nginx swap to the new color  ──fails──▶  Automatic rollback to
        ↓                                         the previous color
Re-validate the public endpoint (8081)
        ↓
Customer/User Browser
```

See `terraform/README.md` for how the blue/green router actually works.

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
{"status":"healthy","version":"a1b2c3d","color":"green"}
```

`color` reflects whichever side (blue or green) is currently live, and `version` is the deployed commit's short SHA — both set by the deploy workflow, so a response always proves which release actually answered it.

## Interview Answer

I automated deployment processes using GitHub Actions to eliminate manual deployment errors. The pipeline checks out code, installs dependencies, runs tests, scans for vulnerabilities, builds a Docker image, and deploys it to an AWS EC2 server using a single-host blue/green pattern: the new version is validated on an internal port before it receives any real traffic, promoted via an nginx config swap, re-validated against the public endpoint, and automatically rolled back to the previous version if that final check fails. This reduced operational risk, improved release consistency, prevented wrong-version or skipped-validation deployments, and gave the pipeline an actual recovery path instead of just a way to notice a bad release after the fact.
