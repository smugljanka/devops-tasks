data "aws_availability_zones" "available" {}

# Cloudfront prefix list com.amazonaws.global.cloudfront.origin-facing
data "aws_prefix_list" "cloudfront_global" {

  filter {
    name   = "prefix-list-id"
    values = ["pl-4fa04526"]
  }
}