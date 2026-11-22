terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_instance" "app" {
  instance_id = "i-008946d3d340ee1bf"
}

data "aws_vpc" "app" {
  id = "vpc-087053f8a31ed7547"
}

data "aws_subnet" "app" {
  id = "subnet-01a09a730bd4383ac"
}

data "aws_security_group" "app" {
  id = "sg-0f95afc73710e2239"
}

output "ec2_public_ip" {
  value = data.aws_instance.app.public_ip
}

output "ec2_instance_type" {
  value = data.aws_instance.app.instance_type
}

output "vpc_id" {
  value = data.aws_vpc.app.id
}

output "subnet_id" {
  value = data.aws_subnet.app.id
}

output "security_group_id" {
  value = data.aws_security_group.app.id
}