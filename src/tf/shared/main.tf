## ACM ##
resource "aws_acm_certificate" "cert01" {
  provider = aws.us_east_1
  private_key=file("privkey.pem")
  certificate_body = file("cert.pem")
  certificate_chain=file("fullchain.pem")
}

## CLOUDFRONT ##

resource "aws_cloudfront_function" "cf_function_01" {
  provider = aws.us_east_1
  name     = "viewer-request-01"
  comment  = "Multipurpose function"
  runtime  = "cloudfront-js-2.0"
  code     = file("${path.module}/cf-function-viewer-request.js")
  publish  = true
}

module "cf_distribution_01" {
  depends_on = [
   aws_acm_certificate.cert01,
   aws_cloudfront_function.cf_function_01
  ]

  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  aliases = ["${var.ADN-DASHBOARD}"]

  comment             = "Shared distribution for ${var.WWW_URI}'s dashboard"
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
  create_origin_access_control = false

  origin = {
    primaryK8S = {
      domain_name = var.AWS_CF_ORIGIN_JLV6_URI_DAHSBOARD
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_header = [
        {
          name  = "x-deployment-environment"
          value = "${var.X-DEPLOYMENT-ENVIRONMENT}"
        }
      ]
    }
  }

  default_cache_behavior = {
    target_origin_id       = "primaryK8S"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.cf_function_01.arn
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert01.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

module "cf_distribution_02" {
  depends_on = [
   aws_acm_certificate.cert01,
   aws_cloudfront_function.cf_function_01
  ]

  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  aliases = ["${var.ADN-WIKI}"]

  comment             = "Shared distribution for ${var.WWW_URI}'s wiki"
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
  create_origin_access_control = false

  origin = {
    primaryK8S = {
      domain_name = var.AWS_CF_ORIGIN_JLV6_URI_WIKI
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_header = [
        {
          name  = "x-deployment-environment"
          value = "${var.X-DEPLOYMENT-ENVIRONMENT}"
        }
      ]
    }
  }

  default_cache_behavior = {
    target_origin_id       = "primaryK8S"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.cf_function_01.arn
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert01.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}