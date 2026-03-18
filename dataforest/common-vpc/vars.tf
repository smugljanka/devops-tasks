variable "project" {
  type    = string
  default = "dataforest"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  default = "eu-west-1"
}

variable "profile" {
  default = "default"
}

variable "common_tags" {
  type = map(string)

  default = {
    Owner = "marivankatov@gmail.com",
  }
}

#Infra VPC
variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "single_nat_gateway" {
  description = "Whether to setup a single NAT GW for all AZs or a single one per AZ"
  type        = bool
  default     = true
}

locals {
  common_tags = merge({ Env = var.env, Project = var.project }, var.common_tags)

  # split VPC CIDR to three IP blocks for pub, pri, pri_db subnets
  cidr_blocks = cidrsubnets(var.vpc_cidr, 4, 4, 4)

  pub_cidr_blocks = local.cidr_blocks[0] # "10.100.0.0/20" 4094
  pri_cidr_blocks = local.cidr_blocks[1] # "10.100.16.0/20"

  # public LB subnet CIDRs per AZ
  pub_lb_cidr_az1 = cidrsubnet(local.pub_cidr_blocks, 4, 0) # "10.100.0.0/24" (250 IPs)
  pub_lb_cidr_az2 = cidrsubnet(local.pub_cidr_blocks, 4, 1) # "10.100.1.0/24"
  pub_lb_cidrs    = [local.pub_lb_cidr_az1, local.pub_lb_cidr_az2]

  # private FE subnet CIDRs per AZ
  pri_fe_cidr_az1 = cidrsubnet(local.pri_cidr_blocks, 4, 0) # "10.100.16.0/24" (250 IPs)
  pri_fe_cidr_az2 = cidrsubnet(local.pri_cidr_blocks, 4, 1) # "10.100.17.0/24"
  pri_fe_cidrs    = [local.pri_fe_cidr_az1, local.pri_fe_cidr_az2]

  # private BE subnet CIDRs per AZ
  pri_be_cidr_az1 = cidrsubnet(local.pri_cidr_blocks, 4, 3) # "10.100.19.0/24" (250 IPS)
  pri_be_cidr_az2 = cidrsubnet(local.pri_cidr_blocks, 4, 4) # "10.100.20.0/24"
  pri_be_cidrs    = [local.pri_be_cidr_az1, local.pri_be_cidr_az2]

  # private DB subnet CIDR per AZ
  pri_db_cidr_az1 = cidrsubnet(local.pri_cidr_blocks, 4, 6) # "10.100.22.0/24" (250 IPS)
  pri_db_cidr_az2 = cidrsubnet(local.pri_cidr_blocks, 4, 7) # "10.100.23.0/24"
  pri_db_cidrs    = [local.pri_db_cidr_az1, local.pri_db_cidr_az2]
}