module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases         = []
  comment         = "CloudFront distribution to S3 origin"
  enabled         = var.create_cf
  http_version    = "http2and3"
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"

  origin_access_control = {
    s3 = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3_bucket = {
      domain_name = aws_s3_bucket.cf_frontend.bucket_regional_domain_name
    }
  }

  vpc_origin = {
    ec2 = {
      arn                    = module.fe[0].arn
      http_port              = 8080
      origin_protocol_policy = "http-only"

      timeouts = {
        create = "20m"
        update = "20m"
        delete = "20m"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "ec2"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-caching-optimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_bucket"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_name = "Managed-CachingOptimized"
      compress          = true
      query_string      = true
    }
  ]
}