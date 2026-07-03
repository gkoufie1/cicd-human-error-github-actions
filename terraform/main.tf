terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "github_actions_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_security_group" "cicd_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for GitHub Actions CI/CD EC2 deployment server"

  ingress {
    description = "SSH from your IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Application port"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_instance" "cicd_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.github_actions_key.key_name
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]

  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -eux
    apt-get update -y
    apt-get install -y docker.io git curl ca-certificates
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
    docker --version
  EOF_USERDATA

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-ec2"
    Project     = var.project_name
    Environment = var.environment
  }
}
