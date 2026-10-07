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
Deploy to INACTIVE color (blue or green) on an internal port
        ↓
Staging validation directly against that internal port
        ↓               \
  validation passes       validation fails
        ↓                       ↓
Promote: flip nginx to    Stop here — production
the new color, reload     never touched, workflow
        ↓                 fails loudly
Re-validate the real
public endpoint (8081)
        ↓               \
   still healthy          check fails
        ↓                       ↓
   Done                   Automatic rollback:
                           flip nginx back to the
                           previous color, reload,
                           fail the workflow
```

This version replaced a simpler (and riskier) first version: stop the old
container, start the new one, hope it's healthy. The original had **no
rollback path at all** — once the new container was running, the old one
was already gone, and if the new version failed to start cleanly, there
was nothing to go back to.

## Tools Used

- GitHub Actions
- Docker
- Terraform
- AWS EC2
- Ubuntu Linux
- nginx (blue/green traffic router)
- jq
- Python Flask
- Pytest
- Trivy
- MobaXterm

## What the Pipeline Does

Every push to the main branch triggers the GitHub Actions workflow. The workflow checks out the code, installs Python dependencies, runs tests, scans the application files, builds a Docker image, scans the image, and copies it to EC2. From there, deployment is a blue/green swap: the new image goes to whichever color (blue or green) isn't currently serving traffic, gets validated directly on its own internal port, and only then gets promoted — a single nginx config swap and reload — to the public port. A second validation runs against the real public endpoint after promotion; if that fails, the pipeline automatically flips traffic back to the previous color and fails the run, rather than leaving a broken deployment live or reporting a false success.

This creates a repeatable deployment process where every release follows the same path, and a bad release is self-correcting instead of requiring someone to notice and fix it by hand.

## Rollback: The Part the First Version Didn't Have

The first version of this pipeline could deploy, but it couldn't recover. It stopped the running container, started the new one, and that was it — if the new version crashed on startup or failed its health check, there was no "old version" left to fall back to, because it had already been deleted.

The fix was a single-host blue/green pattern: nginx sits in front of two internal ports, each running a container, and only one is "active" at any time via a symlinked config file. A new deploy always goes to the *inactive* side first, gets proven healthy on its own port with zero public exposure, and only then gets promoted by flipping that symlink. The previous version is never deleted until the *next* deploy overwrites it — so if promotion itself turns out to be bad (the public endpoint check fails after the swap), rolling back is just flipping the symlink again, not rebuilding anything.

## Business Value

This project provides several important business benefits:

- Consistent deployments
- Reduced human error
- Reduced outage risk
- Faster release cycles
- Better application reliability
- Stronger customer trust
- Improved auditability
- Automatic rollback on a failed deployment, with no manual intervention
- Near-zero-downtime promotion (a config reload, not a container restart on the live port)

## Why This Matters for Cloud and DevOps Roles

Cloud and DevOps engineers are expected to reduce operational risk through automation. This project demonstrates practical experience with CI/CD, cloud deployment, containerization, security scanning, and release validation.

It shows that I understand not only how to use tools, but why those tools matter to the business.

## Interview Explanation

I automated deployment processes using GitHub Actions to eliminate manual deployment errors. The pipeline checks out code, installs dependencies, runs tests, scans for vulnerabilities, builds a Docker image, and deploys it to an AWS EC2 server using a single-host blue/green pattern: the new version is validated on an internal port before it ever receives real traffic, promoted by an nginx config swap, re-validated against the public endpoint, and automatically rolled back to the previous version if that final check fails. This reduced operational risk, improved release consistency, prevented wrong-version or skipped-validation deployments, and — unlike the pipeline's first version — gave it an actual recovery path when a deployment goes wrong instead of just a way to notice afterward.

## Resume Bullet

Built a GitHub Actions CI/CD pipeline with staged validation, blue/green traffic promotion via nginx, and automated rollback on failed health checks — eliminating both manual deployment errors and the risk of a bad release staying live undetected.
