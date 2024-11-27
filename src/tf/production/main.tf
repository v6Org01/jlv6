## IAM ##

resource "aws_iam_role" "iam_role_01" {
  provider = aws.us_east_1
  name = "lambdaExecRole-httpModifyHeadeHost-jlv6-production"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "iam_doc_policy_01" {
  provider = aws.us_east_1
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/httpModifyHeaderHost-jlv6-production:*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/httpModifyHeaderHost-jlv6-production:*.*",
    ]
  }
}

data "aws_iam_policy_document" "iam_doc_policy_02" {
  depends_on = [
    module.cf_distribution_01
  ]
  provider = aws.us_east_1
  statement {
    actions = [
      "cloudfront:UpdateDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:CreateInvalidation"
    ]
    resources = [module.cf_distribution_01.cloudfront_distribution_arn]
  }
}

resource "aws_iam_policy" "iam_policy_01" {
  provider    = aws.us_east_1
  name        = "lambda-cloudwatchLogs-httpModifyHeaderHost-jlv6-production"
  description = "Policy to allow logging to CloudWatch log group for Lambda@Edge function"
  policy      = data.aws_iam_policy_document.iam_doc_policy_01.json
}

resource "aws_iam_policy" "iam_policy_02" {
  provider    = aws.us_east_1
  name        = "lambda-cloudfront-httpModifyHeaderHost-jlv6-production"
  description = "Policy to manage CloudFront distribution for Lambda@Edge"
  policy      = data.aws_iam_policy_document.iam_doc_policy_02.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_01" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_01.name
  policy_arn = aws_iam_policy.iam_policy_01.arn
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_02" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_01.name
  policy_arn = aws_iam_policy.iam_policy_02.arn
}

## CLOUDWATCH ##

module "cw_logs_01" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.us_east_1
  }
  logs_path = "/aws/lambda/httpModifyHeaderHost-jlv6-production"
  log_group_retention_in_days = 14
}

## S3 ##

module "s3_bucket_01" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  providers = {
    aws = aws.eu_central_1
  }
  bucket   = var.AWS_S3_BUCKET_01

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_policy = false

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "s3_policy_doc_01" {
  depends_on = [
    module.s3_bucket_01,
    module.cf_distribution_01
  ]
  provider = aws.eu_central_1
  statement {
    sid = "AllowCloudFrontAccess"
    actions = ["s3:GetObject"]
    resources = ["${module.s3_bucket_01.s3_bucket_arn}/*"]
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

resource "aws_s3_bucket_policy" "s3_policy_01" {
  provider = aws.eu_central_1
  depends_on = [
    data.aws_iam_policy_document.s3_policy_doc_01
  ]
  bucket = module.s3_bucket_01.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy_doc_01.json
}

module "s3_bucket_02" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  providers = {
    aws = aws.eu_central_1
  }
  bucket   = var.AWS_S3_BUCKET_02

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_policy = false

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "s3_policy_doc_02" {
  depends_on = [
    module.s3_bucket_02,
    module.cf_distribution_01
  ]
  provider = aws.eu_central_1
  statement {
    sid = "AllowCloudFrontAccess"
    actions = ["s3:PutObject"]
    resources = ["${module.s3_bucket_02.s3_bucket_arn}/*"]
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

resource "aws_s3_bucket_policy" "s3_policy_02" {
  provider = aws.eu_central_1
  depends_on = [
    data.aws_iam_policy_document.s3_policy_doc_02
  ]
  bucket = module.s3_bucket_02.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy_doc_02.json
}

## CLOUDFRONT ##

module "cf_distribution_01" {
  depends_on = [
   module.s3_bucket_01,
   module.s3_bucket_02
  ]

  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  aliases = ["${var.ADN}"]

  comment             = "Production distribution for ${var.WWW_URI}"
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
    s3_oac_02 = {
      description      = "OAC for ${module.s3_bucket_01.s3_bucket_id} bucket"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  logging_config = {
    bucket = module.s3_bucket_02.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }

  origin = {
    primaryK8S = {
      domain_name = var.AWS_CF_ORIGIN_JLV6_URI
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_header = [
        {
          name  = "X-Deployment-Location"
          value = "k8s"
        },
        {
          name  = "X-Deployment-Environment"
          value = "${var.X-DEPLOYMENT-ENVIRONMENT}"
        }
      ]
    }
    failoverS3 = {
      domain_name           = module.s3_bucket_01.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac_02"
      origin_path           = "/${var.VERSION}"
      custom_header = [
        {
          name  = "X-Deployment-Location"
          value = "aws"
        }
      ]
    }
  }

  origin_group = {
    origGroup01 = {
      failover_status_codes      = [404, 500, 502, 503, 504]
      primary_member_origin_id   = "primaryK8S"
      secondary_member_origin_id = "failoverS3"
    }
  }

  ordered_cache_behavior = [
    {
      path_pattern     = "/index.html"
      target_origin_id = "origGroup01"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      use_forwarded_values         = false
      cache_policy_id              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
      origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06

      function_association = {
        # Valid keys: viewer-request, viewer-response
        viewer-request = {
          function_arn = data.terraform_remote_state.shared.outputs.aws_cloudfront_function_cf_function_01_arn
        }
      }
      lambda_function_association = {
        origin-request = {
          include_body = false
          lambda_arn = module.lambda_at_edge_01.lambda_function_qualified_arn
        }
      }
    }
  ]
  
  default_cache_behavior = {
    target_origin_id       = "origGroup01"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06

    function_association = {
      # Valid keys: viewer-request, viewer-response
      viewer-request = {
        function_arn = data.terraform_remote_state.shared.outputs.aws_cloudfront_function_cf_function_01_arn
      }
    }
    lambda_function_association = {
      origin-request = {
        include_body = false
        lambda_arn = module.lambda_at_edge_01.lambda_function_qualified_arn
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.terraform_remote_state.shared.outputs.aws_acm_certificate_cert01_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

# LAMBDA ##

data "archive_file" "archive_01" {
  type        = "zip"
  source_file = "${path.module}/lambda-httpModifyHeaderHost.mjs"
  output_path = "${path.module}/lambda-httpModifyHeaderHost.mjs.zip"
}

module "lambda_at_edge_01" {
  depends_on = [
    data.archive_file.archive_01,
    module.cw_logs_01
  ]

  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.us_east_1
  }

  lambda_at_edge = true
  publish        = true

  create_package         = false
  local_existing_package = data.archive_file.archive_01.output_path
  
  architectures = ["x86_64"]
  function_name = "httpModifyHeaderHost-jlv6-production"
  description   = "Sets host header value to Production S3_bucket when CloudFront origin request to S3.origin"
  handler       = "lambda-httpModifyHeaderHost.handler"
  runtime       = "nodejs20.x"

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn
  
  use_existing_cloudwatch_log_group  = true
  attach_cloudwatch_logs_policy      = false
  attach_create_log_group_permission = false
  logging_log_group                  = module.cw_logs_01.log_group_name
}