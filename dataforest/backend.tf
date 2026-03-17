terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "dataforest-dev-terraform-state-backend"
    encrypt = true
    key     = "infra/terraform.tfstate"
    profile = "default"
  }
}
