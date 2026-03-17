resource "aws_s3_bucket" "tf_backend" {

  bucket = "${var.project}-${var.env}-terraform-state-backend"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_versioning" "tf_backend" {

  bucket = aws_s3_bucket.tf_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend" {

  bucket = aws_s3_bucket.tf_backend.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_backend" {

  bucket              = aws_s3_bucket.tf_backend.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

data "aws_iam_policy_document" "tf_backend" {

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.tf_backend.arn,
      "${aws_s3_bucket.tf_backend.arn}/*"
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
}

resource "aws_s3_bucket_policy" "tf_backend" {

  bucket = aws_s3_bucket.tf_backend.id
  policy = data.aws_iam_policy_document.tf_backend.json
}
