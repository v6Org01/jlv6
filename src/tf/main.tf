# S3 BUCKET PROD01
resource "aws_s3_bucket" "prod01" {
  bucket = var.AWS_PROD_S3_BUCKET_NAME
}

resource "aws_s3_bucket_ownership_controls" "prod01" {
  bucket = aws_s3_bucket.prod01.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "prod01" {
  bucket = aws_s3_bucket.prod01.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "prod01" {
  depends_on = [
    aws_s3_bucket_ownership_controls.prod01,
    aws_s3_bucket_public_access_block.prod01,
  ]
  bucket = aws_s3_bucket.prod01.id
  acl    = "public-read"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod01" {
  bucket = aws_s3_bucket.prod01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "prod01" {
  bucket = aws_s3_bucket.prod01.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_policy" "prod01" {
  bucket = aws_s3_bucket.prod01.id
  policy = data.aws_iam_policy_document.publicRead.json
}

data "aws_iam_policy_document" "publicRead" {
  statement {
    sid = "PublicRead"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "arn:aws:s3:::${var.AWS_PROD_S3_BUCKET_NAME}/*"
    ]
  }
}

# CLOUDFRONT
