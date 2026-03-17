variable "project" {
  type    = string
  default = "dataforest"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "common_tags" {
  type = map(string)

  default = {
    Owner = "marivankatov@gmail.com",
  }
}

#EC2 instance settings
variable "fe_instance_configs" {
  description = "Specifies mapping of EC2 instance configuration per a FE instance"
  type = map(
    object({
      instance_type     = string
      ebs_volumes       = any
      root_block_device = any
      }
    )
  )
  default = {
    "1" = {
      # See https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/variables.tf for details
      instance_type = "t2.micro",
      ebs_volumes   = null,
      root_block_device = {
        encrypted = true,
        type      = "gp3",
        size      = 10
      }
    }
  }
}

variable "instance_key_pair" {
  type    = string
  default = "my_key"
}

variable "instance_profile_policies" {
  type = map(string)
  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }
}

variable "init_userdata" {
  description = "A flag that specifies whether to configure EC2 user data while provisioning EC2 instances"
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  default = {
    create = "10m",
    update = "10m",
    delete = "10m"
  }
}

#ALB/CloudFront settings
variable "certificate_arn" {
  description = "The AWS ACM certificate ARN for an origin domain"
  type    = string
  default = "arn:aws:acm:eu-west-1:761554981765:certificate/9822dc38-cef8-4bd5-ab0e-f2c19da32b6c"
}

variable "additional_certificate_arns" {
  type    = list(string)
  default = []
}

variable "create_alb" {
  description = "A flag that indicates whether to setup ALB"
  type        = bool
  default     = false
}

variable "create_cf" {
  description = "A flag that indicates whether to setup CloudFront distribution"
  type        = bool
  default     = false
}

locals {
  common_tags = merge(
    { Env = var.env, Project = var.project },
    var.common_tags
  )
}