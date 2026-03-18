resource "aws_s3_bucket" "cf_frontend" {
  bucket = "amzn-${var.project}-${var.env}-cf-frontend"
}

resource "aws_s3_bucket_versioning" "cf_frontend" {

  bucket = aws_s3_bucket.cf_frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cf_frontend" {

  bucket = aws_s3_bucket.cf_frontend.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cf_frontend" {

  bucket              = aws_s3_bucket.cf_frontend.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

data "aws_iam_policy_document" "cf_frontend" {

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.cf_frontend.arn,
      "${aws_s3_bucket.cf_frontend.arn}/*"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }

    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cf_frontend.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        module.cdn.cloudfront_distribution_arn
        #        "arn:${data.aws_partition.current.partition}:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_frontend" {

  bucket = aws_s3_bucket.cf_frontend.id
  policy = data.aws_iam_policy_document.cf_frontend.json
}
