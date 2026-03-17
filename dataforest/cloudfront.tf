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

  default_cache_behavior = {
    path_pattern           = "/static/*"
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  depends_on = [aws_s3_bucket.cf_frontend]
}