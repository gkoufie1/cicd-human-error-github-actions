variable "aws_region" {
  description = "AWS region for the EC2 deployment server"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
  default     = "cicd-human-error-demo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Name of the AWS key pair Terraform will create"
  type        = string
  default     = "github-actions-cicd-key"
}

variable "public_key" {
  description = "Public SSH key content. Example: ssh-rsa AAAA..."
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR format. Example: 203.0.113.10/32"
  type        = string
}
