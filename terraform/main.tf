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

# IAM Role for EC2 to allow pulling images from ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach the AWS managed policy for ECR read-only access
resource "aws_iam_role_policy_attachment" "ec2_ecr_policy_attachment" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an instance profile to attach the role to the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name
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
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS in us-east-1. Change if your region is different.
  instance_type          = "t2.micro"             # Free tier eligible
  security_groups        = [aws_security_group.strapi_sg.name]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # This script runs on instance startup
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # The instance role handles ECR authentication, so we just need to pull and run
              sudo docker run -d -p 1337:1337 --restart unless-stopped --name strapi ${var.docker_image_uri}
              EOF

  tags = {
    Name = "Strapi-Server"
  }
}
