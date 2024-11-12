# S3
module "s3_bucket_01" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.AWS_S3_BUCKET_01

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_policy_01.json 

  website = {
    index_document = "index.html"
    error_document = "404.html"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "s3_policy_01" {
  statement {
    sid = "AllowCloudFrontAccess"
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${module.s3_bucket_01.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cf_distribution_01.cloudfront_distribution_arn]
    }
    effect = "Allow"
  }
}

# ACM
resource "aws_acm_certificate" "cert01" {
  private_key=file("privkey.pem")
  certificate_body = file("cert.pem")
  certificate_chain=file("fullchain.pem")
}

# CLOUDFRONT
module "cf_distribution_01" {
  # Ensure CloudFront distribution creation happens after ACM_CERT is created
  depends_on = [
   aws_acm_certificate.cert01
  ]

  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["${var.JLV6_URI}"]

  comment             = "CloudFront distribution for ${var.JLV6_URI}"
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = true

  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB", "DE", "FR", "BE", "NL", "LU"]
  }

  create_origin_access_identity = false
  create_origin_access_control = true
  origin_access_control = {
    s3_oac_01 = {
      description      = "OAC for ${module.s3_bucket_01.s3_bucket_id} bucket"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = [
    {
      origin_id   = "primaryK8S"
      domain_name = var.JLV6_DOMAIN
      custom_origin_config = {
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_header = {
        name = "X-Deployment-Location"
        value = "k8s"
      }
      origin_shield = {
        enabled = false
      }
    },
    {
      origin_id   = "failoverS3"
      domain_name = module.s3_bucket_01.s3_bucket_bucket_regional_domain_name
      custom_origin_config = {
        http_port              = 80
        origin_protocol_policy = "http-only"
      }
      custom_header = {
        name = "X-Deployment-Location"
        value = "aws"
      }
      origin_shield = {
        enabled = false
      }
      origin_access_control = "s3_oac_01"
    }
  ]

  origin_groups = [
    {
      origin_group_id = "origGroup01"
      failover_criteria = {
        status_codes = [500, 502, 503, 504]
      }
      members = [
        { origin_id = "primaryK8S" },
        { origin_id = "failoverS3" }
      ]
    }
  ]
  
  ordered_cache_behavior = {
    path_pattern     = "/${var.APPLICATION_VERSION}/*"
    target_origin_id = "failoverS3"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values = false
  }

  default_cache_behavior = {
    target_origin_id       = "origGroup01"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values = false
  }

  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.cert01.arn
  }
}