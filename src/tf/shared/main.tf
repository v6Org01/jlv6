## IAM ##

resource "aws_iam_role" "iam_role_01" {
  provider = aws.us_east_1
  name = "lambdaExecRole-jlv6"
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

resource "aws_iam_role" "iam_role_02" {
  provider = aws.us_east_1
  name = "EventBridgeSchedRole-jlv6"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "events.amazonaws.com"
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
      "logs:*",
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "iam_doc_policy_02" {
  provider = aws.us_east_1
  statement {
    actions = [
      "cloudfront:UpdateDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "arn:aws:cloudfront:::distribution/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/jlv6-com"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "iam_doc_policy_03" {
  provider = aws.us_east_1
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.lambda_01.lambda_function_qualified_arn,
      module.lambda_02.lambda_function_qualified_arn
    ]
  }
}

resource "aws_iam_policy" "iam_policy_01" {
  provider    = aws.us_east_1
  name        = "lambda-cloudwatchLogs-jlv6-shared"
  description = "Policy to allow logging to CloudWatch log groups for Lambda@Edge functions"
  policy      = data.aws_iam_policy_document.iam_doc_policy_01.json
}

resource "aws_iam_policy" "iam_policy_02" {
  provider    = aws.us_east_1
  name        = "lambda-cloudfront-jlv6-shared"
  description = "Policy to manage CloudFront distribution for Lambda@Edge"
  policy      = data.aws_iam_policy_document.iam_doc_policy_02.json
}

resource "aws_iam_policy" "iam_policy_03" {
  provider    = aws.us_east_1
  name        = "eventBridge-lambda-jlv6-shared"
  description = "Policy to invoke Lambda Functions from EventBridge"
  policy      = data.aws_iam_policy_document.iam_doc_policy_03.json
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

resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_03" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_02.name
  policy_arn = aws_iam_policy.iam_policy_03.arn
}

## EVENTBRIDGE ##

resource "aws_cloudwatch_event_rule" "every_minute_01" {
  provider   = aws.us_east_1
  name        = "every-minute-rule-us"
  description = "Trigger Lambda every minute in us-east-1"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_rule" "every_minute_02" {
  provider   = aws.eu_central_1
  name       = "every-minute-rule-eu"
  description = "Trigger Lambda every minute in eu-west-1"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target_01" {
  depends_on = [
    module.lambda_01
  ]
  provider  = aws.us_east_1
  rule      = aws_cloudwatch_event_rule.every_minute_01.name
  target_id = "lambda-target-us"
  arn       = module.lambda_01.lambda_function_qualified_arn
  role_arn  = aws_iam_role.iam_role_02.arn 
}

resource "aws_cloudwatch_event_target" "lambda_target_02" {
  depends_on = [
    module.lambda_02
  ]
  provider  = aws.eu_central_1
  rule      = aws_cloudwatch_event_rule.every_minute_02.name
  target_id = "lambda-target-eu"
  arn       = module.lambda_02.lambda_function_qualified_arn
  role_arn  = aws_iam_role.iam_role_02.arn 
}

## CLOUDWATCH ##

/* module "cw_logs_01" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.us_east_1
  }
  logs_path = "/aws/lambda/viewerReq-Bots-OpenObserve-jlv6-shared"
  log_group_retention_in_days = 7 
} */

/* module "cw_logs_02" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.us_east_1
  }
  logs_path = "/aws/lambda/httpCheck-OpenObserve-jlv6-shared"
  log_group_retention_in_days = 7 
} */

/* module "cw_logs_03" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.eu_central_1
  }
  logs_path = "/aws/lambda/httpCheck-OpenObserve-jlv6-shared"
  log_group_retention_in_days = 7 
} */

## S3 ##

module "s3_bucket_01" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  providers = {
    aws = aws.eu_central_1
  }
  bucket   = var.AWS_S3_BUCKET_01

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

data "aws_iam_policy_document" "s3_policy_doc_01" {
  depends_on = [
    module.s3_bucket_01
  ]
  provider = aws.eu_central_1
  statement {
    sid = "AllowCloudFrontAccess"
    actions = ["s3:PutObject"]
    resources = ["${module.s3_bucket_01.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::*:distribution/*"]
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

## ACM ##
resource "aws_acm_certificate" "cert01" {
  provider = aws.us_east_1
  private_key=file("privkey.pem")
  certificate_body = file("cert.pem")
  certificate_chain=file("fullchain.pem")
}

## CLOUDFRONT ##

/* resource "aws_cloudfront_function" "cf_function_01" {
  provider = aws.us_east_1
  name     = "viewer-request-01"
  comment  = "Multipurpose function"
  runtime  = "cloudfront-js-2.0"
  code     = file("${path.module}/cf-function-viewer-request.js")
  publish  = true
} */

/* module "cf_distribution_01" {
  depends_on = [
   aws_acm_certificate.cert01,
   module.lambda_at_edge_01,
   module.s3_bucket_01
  ]

  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  tags = {
    custom-name = "jlv6-prod-dash"
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

  logging_config = {
    bucket = module.s3_bucket_01.s3_bucket_bucket_domain_name
    prefix = "cf_dashboard"
  }

  origin = {
    primaryK8S = {
      domain_name = var.AWS_CF_ORIGIN_JLV6_URI_DAHSBOARD
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "primaryK8S"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06
    response_headers_policy_id   = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.cf_function_01.arn
      }
    }

    lambda_function_association = {
      viewer-request = {
        include_body = false
        lambda_arn   = module.lambda_at_edge_01.lambda_function_qualified_arn
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert01.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
} */

/* module "cf_distribution_02" {
  depends_on = [
   aws_acm_certificate.cert01,
   module.lambda_at_edge_01,
   module.s3_bucket_01
  ]

  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  tags = {
    custom-name = "jlv6-prod-grafana"
  }

  aliases = ["${var.ADN-GRAFANA}"]

  comment             = "Shared distribution for ${var.WWW_URI}'s grafana dashboards"
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

  logging_config = {
    bucket = module.s3_bucket_01.s3_bucket_bucket_domain_name
    prefix = "cf_grafana"
  }

  origin = {
    primaryK8S = {
      domain_name = var.AWS_CF_ORIGIN_JLV6_URI_GRAFANA
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "primaryK8S"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06
    response_headers_policy_id   = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.cf_function_01.arn
      }
    }

    lambda_function_association = {
      viewer-request = {
        include_body = false
        lambda_arn   = module.lambda_at_edge_01.lambda_function_qualified_arn
      }
    } 
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert01.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
} */

## LAMBDA ##

data "archive_file" "archive_01" {
  type        = "zip"
  source_file = "${path.module}/lambda-viewerReq-Bots-OpenObserve.mjs"
  output_path = "${path.module}/lambda-viewerReq-Bots-OpenObserve.mjs.zip"
}

data "archive_file" "archive_02" {
  type        = "zip"
  source_file = "${path.module}/lambda-httpCheck-OpenObserve.mjs"
  output_path = "${path.module}/lambda-httpCheck-OpenObserve.mjs.zip"
}

module "lambda_at_edge_01" {
  depends_on = [
    data.archive_file.archive_01
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
  function_name = "viewerReq-Bots-OpenObserve-jlv6-shared"
  description   = "Ban crawler bots and ship logs to OpenObserve"
  handler       = "lambda-viewerReq-Bots-OpenObserve.handler"
  runtime       = "nodejs20.x"

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn
  
  use_existing_cloudwatch_log_group  = false
  # logging_log_group                  = module.cw_logs_01.log_group_name
  logging_log_format                 = "JSON"
  logging_application_log_level      = "INFO"
}

module "lambda_01" {
  depends_on = [
    data.archive_file.archive_02
  ]

  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.us_east_1
  }

  lambda_at_edge = false
  publish        = true

  create_package         = false
  local_existing_package = data.archive_file.archive_02.output_path
  
  architectures = ["x86_64"]
  function_name = "httpCheck-OpenObserve-jlv6-shared"
  description   = "Monitor URLs from the US and ship result to OpenObserve"
  handler       = "lambda-httpCheck-OpenObserve.handler"
  runtime       = "nodejs20.x"
  timeout       = 5

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn
  
  use_existing_cloudwatch_log_group  = false
  # logging_log_group                  = module.cw_logs_02.log_group_name
  logging_log_format                 = "JSON"
  logging_application_log_level      = "INFO"
}

module "lambda_02" {
  depends_on = [
    data.archive_file.archive_02
  ]

  source = "terraform-aws-modules/lambda/aws"
  providers = {
    aws = aws.eu_central_1
  }

  lambda_at_edge = false
  publish        = true

  create_package         = false
  local_existing_package = data.archive_file.archive_02.output_path
  
  architectures = ["x86_64"]
  function_name = "httpCheck-OpenObserve-jlv6-shared"
  description   = "Monitor URLs from the EU and ship result to OpenObserve"
  handler       = "lambda-httpCheck-OpenObserve.handler"
  runtime       = "nodejs20.x"
  timeout       = 5

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn

  use_existing_cloudwatch_log_group  = false
  # logging_log_group                  = module.cw_logs_03.log_group_name
  logging_log_format                 = "JSON"
  logging_application_log_level      = "INFO"
}