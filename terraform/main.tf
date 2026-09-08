terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "network" { source = "./modules/network" }

resource "aws_security_group" "bastion" {
  name   = "bastion-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bastion-sg" }
}

resource "aws_security_group" "app" {
  name   = "app-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg" }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.network.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = aws_key_pair.homelab.key_name
  tags                   = { Name = "bastion" }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.network.private_subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.homelab.key_name
  tags                   = { Name = "app" }
}
resource "tls_private_key" "homelab" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "homelab" {
  key_name   = "homelab-key-tf"
  public_key = tls_private_key.homelab.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/homelab-key.pem"
  content         = tls_private_key.homelab.private_key_openssh
  file_permission = "0400"
}
