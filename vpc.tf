provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "subnet_a" {
  id = var.subnet_a
}

data "aws_subnet" "subnet_b" {
  id = var.subnet_b
}

data "aws_subnet" "subnet_c" {
  id = var.subnet_c
}

resource "aws_security_group" "sg_id" {
  name        = "eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
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
