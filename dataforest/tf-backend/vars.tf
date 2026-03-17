variable "project" {
  type    = string
  default = "dataforest"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  description = "The specific region where resources will be managed"
  type = string
  default = "eu-west-1"
}

variable "profile" {
  type = string
  default = "default"
}

variable "common_tags" {
  type = map(string)

  default = {
    Owner = "marivankatov@gmail.com",
  }
}

locals {
  common_tags = merge(
    { Env = var.env, Project = var.project },
    var.common_tags
  )
}