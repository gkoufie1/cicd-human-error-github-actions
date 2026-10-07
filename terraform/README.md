# Terraform EC2 Deployment Server

This Terraform code provisions an Ubuntu EC2 instance for a GitHub Actions CI/CD deployment demo.

## What it creates

- Ubuntu EC2 instance
- Security group (SSH from your IP only, application access on port 8081 — that's it; the internal blue/green ports below are never opened externally)
- Docker, nginx, and jq installed through user data
- Encrypted GP3 root volume

## Blue/green deployment

The instance doesn't run the app container directly on the public port. Instead:

- nginx listens on the public port (8081) and proxies to whichever internal port is currently active: `127.0.0.1:8091` (blue) or `127.0.0.1:8092` (green).
- Which one is active is tracked by a symlink, `/etc/nginx/active/current.conf`, pointing at either `/etc/nginx/upstreams/blue.conf` or `green.conf`.
- The GitHub Actions workflow always deploys to the *inactive* color, validates it directly on its internal port, and only then flips the symlink and reloads nginx to promote it. See `.github/workflows/cicd.yml` for the full staging/promote/rollback logic.
- The instance boots with blue set active by default, but nothing is actually running there yet — the first real deploy goes to green and promotes from there.

**Important:** changing `user_data` (the nginx/Docker setup script) forces Terraform to destroy and recreate the EC2 instance — there's no Elastic IP here, so the instance's public IP changes on every `apply` that touches `user_data`. Update the `EC2_HOST` GitHub secret to match after any such apply, before the next push triggers a deploy.

## Commands

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## Destroy resources

```bash
terraform destroy -auto-approve
```
