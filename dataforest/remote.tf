data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.env}-vpc"]
  }
}

data "aws_subnets" "pub_lb_subnets" {
  filter {
    name = "tag:Name"
    values = [
      "${var.project}-${var.env}-pub-lb-sn-az*"
    ]
  }
}

data "aws_security_group" "pub_lb_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.env}-pub-lb-sg"]
  }
}

data "aws_subnets" "pri_fe_subnets" {
  filter {
    name = "tag:Name"
    values = [
      "${var.project}-${var.env}-pri-fe-sn-az*"
    ]
  }
}

data "aws_security_group" "pri_fe_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.env}-pri-fe-sg"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}