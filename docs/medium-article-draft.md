# How I Reduced Deployment Human Error Using GitHub Actions, Docker, Terraform, and AWS EC2

## Introduction

Many candidates can explain CI/CD, but hiring managers want to know whether you can actually build it and explain the business value. In this project, I focused on one real production problem: human error during manual deployments.

Manual deployments are risky because engineers can forget steps, deploy the wrong application version, skip validation, or miss configuration changes. A simple mistake like deploying version 1.2 instead of version 1.3 can cause downtime, customer complaints, and loss of trust.

## Business Problem

Manual deployments are unreliable. In many organizations, an engineer may have to manually pull code, run tests, build an application, copy files, restart services, and validate the deployment. When this process depends on memory and manual effort, mistakes eventually happen.

Common risks include:

- Forgetting a deployment step
- Deploying the wrong version
- Skipping validation
- Missing configuration changes
- Creating inconsistent environments
- Increasing outage risk

## Real-World Scenario

A developer releases version 1.3 of an application, but during the manual deployment process, an engineer accidentally deploys version 1.2. The application goes live with old code, customers report issues, and the operations team has to troubleshoot what changed.

This is not only a technical issue. It is a business problem because it affects customer trust, operational stability, and release confidence.

## Technical Challenge

The challenge was to create an automated deployment pipeline that performs the same steps every time without depending on manual execution.

The pipeline needed to:

1. Pull the latest code from GitHub
2. Install dependencies
3. Run automated tests
4. Run security scans
5. Build a Docker image
6. Deploy the application to AWS EC2
7. Validate that the application is healthy

## Solution Architecture

The solution uses GitHub Actions as the CI/CD automation engine, Docker for containerization, Terraform for AWS infrastructure provisioning, and EC2 as the deployment server.

Architecture flow:

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
User Accesses Application
```

## Tools Used

- GitHub Actions
- Docker
- Terraform
- AWS EC2
- Ubuntu Linux
- Python Flask
- Pytest
- Trivy
- MobaXterm

## What the Pipeline Does

Every push to the main branch triggers the GitHub Actions workflow. The workflow checks out the code, installs Python dependencies, runs tests, scans the application files, builds a Docker image, scans the image, copies the image to EC2, deploys the container, and validates the health endpoint.

This creates a repeatable deployment process where every release follows the same path.

## Business Value

This project provides several important business benefits:

- Consistent deployments
- Reduced human error
- Reduced outage risk
- Faster release cycles
- Better application reliability
- Stronger customer trust
- Improved auditability

## Why This Matters for Cloud and DevOps Roles

Cloud and DevOps engineers are expected to reduce operational risk through automation. This project demonstrates practical experience with CI/CD, cloud deployment, containerization, security scanning, and release validation.

It shows that I understand not only how to use tools, but why those tools matter to the business.

## Interview Explanation

I automated deployment processes using GitHub Actions to eliminate manual deployment errors. The pipeline checks out code, installs dependencies, runs tests, scans for vulnerabilities, builds a Docker image, deploys it to an AWS EC2 server, and validates the health endpoint. This reduced operational risk, improved release consistency, and helped prevent wrong-version or skipped-validation deployments.

## Resume Bullet

Built a GitHub Actions CI/CD pipeline that automated testing, security scanning, Docker image creation, and deployment to AWS EC2, reducing manual deployment errors and improving release reliability.
