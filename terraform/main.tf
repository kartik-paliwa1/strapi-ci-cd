terraform {
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



# Security Group to allow inbound traffic
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi app traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Open to all. Restrict to your IP in production.
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The EC2 instance itself
resource "aws_instance" "strapi_server" {
  ami             = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS in us-east-1. Change if your region is different.
  instance_type   = "t2.micro"             # Free tier eligible
  security_groups = [aws_security_group.strapi_sg.name]

  # This new script runs on instance startup
  user_data = <<-EOF
              #!/bin/bash
              # Update packages and install Docker
              sudo apt-get update
              sudo apt-get install -y docker.io awscli

              # Start and enable Docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usmod -aG docker ubuntu

              # Configure AWS CLI with credentials passed from Terraform
              mkdir -p /home/ubuntu/.aws
              echo "[default]" > /home/ubuntu/.aws/credentials
              echo "aws_access_key_id = ${var.aws_access_key_id}" >> /home/ubuntu/.aws/credentials
              echo "aws_secret_access_key = ${var.aws_secret_access_key}" >> /home/ubuntu/.aws/credentials
              chown -R ubuntu:ubuntu /home/ubuntu/.aws

              # Log in to AWS ECR
              ECR_REGISTRY=$(echo "${var.docker_image_uri}" | cut -d'/' -f1)
              sudo -u ubuntu aws ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin $ECR_REGISTRY
              
              # Pull and run the Strapi container
              sudo docker run -d -p 1337:1337 --restart unless-stopped --name strapi ${var.docker_image_uri}
              EOF

  tags = {
    Name = "Strapi-Server"
  }
}
