# Terraform EC2 Deployment Server

This Terraform code provisions an Ubuntu EC2 instance for a GitHub Actions CI/CD deployment demo.

## What it creates

- Ubuntu EC2 instance
- Security group
- SSH access from your IP only
- Application access on port 8081
- Docker installation through user data
- Encrypted GP3 root volume

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
