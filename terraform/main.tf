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

  # nginx is the blue/green router: it listens on the one public port
  # (8081, matching the security group) and proxies to whichever internal
  # port — 8091 (blue) or 8092 (green) — is currently marked active. The
  # deploy workflow flips which upstream file is symlinked in and reloads
  # nginx; it never touches the security group or this instance's own
  # networking, so promotion is just a config swap, not new infra.
  user_data = <<-EOF_USERDATA
    #!/bin/bash
    set -eux
    apt-get update -y
    apt-get install -y docker.io git curl ca-certificates nginx jq
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu

    mkdir -p /etc/nginx/active /etc/nginx/upstreams
    cat >/etc/nginx/upstreams/blue.conf <<-'EOF_BLUE'
    set $backend "127.0.0.1:8091";
    EOF_BLUE
    cat >/etc/nginx/upstreams/green.conf <<-'EOF_GREEN'
    set $backend "127.0.0.1:8092";
    EOF_GREEN

    # Starts pointed at blue; the deploy workflow's very first run deploys
    # to green (the inactive color) and promotes from there, so this
    # default never actually serves a real deployment on its own.
    ln -sf /etc/nginx/upstreams/blue.conf /etc/nginx/active/current.conf

    cat >/etc/nginx/sites-available/app <<-'EOF_SITE'
    server {
        listen 8081;
        include /etc/nginx/active/current.conf;
        location / {
            proxy_pass http://$backend;
            proxy_set_header Host $host;
        }
    }
    EOF_SITE
    ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
    rm -f /etc/nginx/sites-enabled/default
    systemctl enable nginx
    systemctl restart nginx

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
