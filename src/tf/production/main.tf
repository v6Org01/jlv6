## IAM ##

resource "aws_iam_role" "iam_role_01" {
  provider = aws.us_east_1
  name = "lambdaExecRole-jlv6-production"
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

/* resource "aws_iam_role" "iam_role_02" {
  provider = aws.us_east_1
  name = "cloudFrontRole-jlv6-production"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudfront.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
} */

/* resource "aws_iam_role" "iam_role_03" {
  provider = aws.us_east_1
  name = "kinesisFirehoseRole-jlv6-production"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "firehose.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
} */

data "aws_iam_policy_document" "iam_doc_policy_01" {
  provider = aws.us_east_1
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/viewerReq-Bots-jlv6-shared:*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/viewerReq-Bots-jlv6-shared:*.*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/originReq-S3-jlv6-production:*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/originReq-S3-jlv6-production:*.*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/originResp-OpenObserve-jlv6-shared:*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/originResp-OpenObserve-jlv6-shared:*.*"
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

/* data "aws_iam_policy_document" "iam_doc_policy_03" {
  depends_on = [
    aws_kinesis_stream.kinesis_stream_01
  ]
  provider = aws.us_east_1
  statement {
    actions = [
      "kinesis:DescribeStreamSummary",
      "kinesis:DescribeStream",
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]
    resources = [aws_kinesis_stream.kinesis_stream_01.arn]
  }
} */

/* data "aws_iam_policy_document" "iam_doc_policy_04" {
  depends_on = [
    aws_kinesis_stream.kinesis_stream_01
  ]
  provider = aws.us_east_1
  statement {
    actions = [
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:DescribeStreamSummary",
      "kinesis:DescribeStream",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_stream.kinesis_stream_01.arn]
  }
} */

/* data "aws_iam_policy_document" "iam_doc_policy_05" {
  depends_on = [
    module.s3_bucket_03 
  ]
  provider = aws.us_east_1
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      "${module.s3_bucket_03.s3_bucket_arn}",
      "${module.s3_bucket_03.s3_bucket_arn}/*"
    ]
  }
} */

/* data "aws_iam_policy_document" "iam_doc_policy_06" {
  depends_on = [
    module.lambda_01
  ]
  provider = aws.us_east_1
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [module.lambda_01.lambda_function_qualified_arn]
  }
} */

resource "aws_iam_policy" "iam_policy_01" {
  provider    = aws.us_east_1
  name        = "lambda-cloudwatchLogs-jlv6-production"
  description = "Policy to allow logging to CloudWatch log groups for Lambda@Edge functions"
  policy      = data.aws_iam_policy_document.iam_doc_policy_01.json
}

resource "aws_iam_policy" "iam_policy_02" {
  provider    = aws.us_east_1
  name        = "lambda-cloudfront-jlv6-production"
  description = "Policy to manage CloudFront distribution for Lambda@Edge"
  policy      = data.aws_iam_policy_document.iam_doc_policy_02.json
}

/* resource "aws_iam_policy" "iam_policy_03" {
  provider    = aws.us_east_1
  name        = "cloudfront-kinesis-stream-jlv6"
  description = "Policy to allow CloudFront to send logs to a Kinesis Stream"
  policy      = data.aws_iam_policy_document.iam_doc_policy_03.json
} */

/* resource "aws_iam_policy" "iam_policy_04" {
  provider    = aws.us_east_1
  name        = "kinesis-firehose-stream-jlv6"
  description = "Policy to allow Kinesis Firehose to read logs from Kinesis Data Stream"
  policy      = data.aws_iam_policy_document.iam_doc_policy_04.json
} */

/* resource "aws_iam_policy" "iam_policy_05" {
  provider    = aws.us_east_1
  name        = "kinesis-firehose-s3-jlv6"
  description = "Policy to allow Kinesis Firehose to manage stream S3 bucket"
  policy      = data.aws_iam_policy_document.iam_doc_policy_05.json
} */

/* resource "aws_iam_policy" "iam_policy_06" {
  provider    = aws.us_east_1
  name        = "kinesis-firehose-lambda-jlv6"
  description = "Policy to allow Kinesis Firehose to invoke lambda function to transform CloudFront (access) logs"
  policy      = data.aws_iam_policy_document.iam_doc_policy_06.json
} */

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

/* resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_03" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_02.name
  policy_arn = aws_iam_policy.iam_policy_03.arn
} */

/* resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_04" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_03.name
  policy_arn = aws_iam_policy.iam_policy_04.arn
} */

/* resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_05" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_03.name
  policy_arn = aws_iam_policy.iam_policy_05.arn
} */

/* resource "aws_iam_role_policy_attachment" "iam_role_policy_attach_06" {
  provider   = aws.us_east_1
  role       = aws_iam_role.iam_role_03.name
  policy_arn = aws_iam_policy.iam_policy_06.arn
} */

## CLOUDWATCH ##

module "cw_logs_01" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.us_east_1
  }
  logs_path = "/aws/lambda/originReq-S3-jlv6-production"
  log_group_retention_in_days = 7
}

/* module "cw_logs_02" {
  source = "cn-terraform/cloudwatch-logs/aws"
  providers = {
    aws = aws.us_east_1
  }
  logs_path = "/aws/lambda/transformCloudfrontAccessLogs-jlv6-production"
  log_group_retention_in_days = 7 
} /*

/* resource "aws_cloudwatch_metric_stream" "cf_metric_stream_01" {
  depends_on = [
    aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_01
  ]
  provider = aws.us_east_1

  name          = "cf-metrics-jlv6"
  firehose_arn  = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_01.arn
  role_arn      = aws_iam_role.iam_role_02.arn
  output_format = "opentelemetry1.0"

  include_filter {
    namespace = "AWS/CloudFront"

    metric_names = [
      "Requests",
      "BytesDownloaded",
      "4xxErrorRate",
      "5xxErrorRate"
    ]
  }
} */

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

/* module "s3_bucket_03" {
  source   = "terraform-aws-modules/s3-bucket/aws"
  providers = {
    aws = aws.us_east_1 
  }
  bucket   = var.AWS_S3_BUCKET_03

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
} */

/* data "aws_iam_policy_document" "s3_policy_doc_03" {
  depends_on = [
    module.s3_bucket_03,
    aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_01
  ]
  provider = aws.us_east_1 
  statement {
    sid = "AllowS3Access"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject" 
    ]
    resources = [
      "${module.s3_bucket_03.s3_bucket_arn}",
      "${module.s3_bucket_03.s3_bucket_arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_01.arn]
    }
    effect = "Allow"
  }
} */

/* resource "aws_s3_bucket_policy" "s3_policy_03" {
  provider = aws.us_east_1
  depends_on = [
    data.aws_iam_policy_document.s3_policy_doc_03
  ]
  bucket = module.s3_bucket_03.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy_doc_03.json
} */

## CLOUDFRONT ##

/* resource "aws_cloudfront_realtime_log_config" "cf_realtime_log_config_01" {
  provider = aws.us_east_1
  depends_on = [
    aws_iam_role.iam_role_02,
    aws_kinesis_stream.kinesis_stream_01
  ]

  name          = "jlv6-www"
  sampling_rate = 100

  fields = [
    # Standard CloudFront Fields
    "timestamp",
    "c-ip",
    "sc-status",
    "cs-method",
    "cs-uri-stem",
    "x-edge-location",
    "cs-user-agent",
    "cs-referer",
    "x-edge-response-result-type",
    "x-edge-result-type",
    
    # CMCD Fields
    "cmcd-encoded-bitrate",
    "cmcd-buffer-length",
    "cmcd-buffer-starvation",
    "cmcd-content-id",
    "cmcd-object-duration",
    "cmcd-deadline",
    "cmcd-measured-throughput",
    "cmcd-next-object-request",
    "cmcd-next-range-request",
    "cmcd-object-type",
    "cmcd-playback-rate",
    "cmcd-requested-maximum-throughput",
    "cmcd-streaming-format",
    "cmcd-session-id",
    "cmcd-stream-type",
    "cmcd-startup",
    "cmcd-top-bitrate",
    "cmcd-version",
    
    # Edge and Request Fields
    "x-edge-mqcs",
    "sr-reason",
    "r-host",
    "x-host-header",
    "x-forwarded-for",
    "x-edge-request-id",
    "x-edge-detailed-result-type",
    
    # Timing and Performance Fields
    "time-to-first-byte",
    "time-taken",
    
    # SSL/TLS Fields
    "ssl-protocol",
    "ssl-cipher",
    
    # Content Range and Type Fields
    "sc-range-start",
    "sc-range-end",
    "sc-content-type",
    "sc-content-len",
    
    # Byte Transfer Fields
    "sc-bytes",
    "s-ip",
    
    # Distribution Fields
    "primary-distribution-id",
    "primary-distribution-dns-name",
    
    # Origin Fields
    "origin-lbl",
    "origin-fbl",
    
    # Field Level Encryption Fields
    "fle-status",
    "fle-encrypted-fields",
    
    # Request Details Fields
    "cs-uri-query",
    "cs-protocol-version",
    "cs-protocol",
    "cs-host",
    "cs-headers-count",
    "cs-headers",
    "cs-header-names",
    "cs-cookie",
    "cs-bytes",
    "cs-accept-encoding",
    "cs-accept",
    
    # Cache and Client Fields
    "cache-behavior-path-pattern",
    "c-port",
    "c-ip-version",
    "c-country",
    "asn"
  ]

  endpoint {
    stream_type = "Kinesis"

    kinesis_stream_config {
      role_arn   = aws_iam_role.iam_role_02.arn
      stream_arn = aws_kinesis_stream.kinesis_stream_01.arn
    }
  }
} */

module "cf_distribution_01" {
  depends_on = [
   module.lambda_at_edge_01,
   module.s3_bucket_01
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
    bucket = data.terraform_remote_state.shared.outputs.module_s3_bucket_01_s3_bucket_bucket_domain_name
    prefix = "cf_production"
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

      # realtime_log_config_arn = aws_cloudfront_realtime_log_config.cf_realtime_log_config_01.arn

      /* function_association = {
        # Valid keys: viewer-request, viewer-response
        viewer-request = {
          function_arn = data.terraform_remote_state.shared.outputs.aws_cloudfront_function_cf_function_01_arn
        }
      } */

      lambda_function_association = {
        viewer-request = {
          include_body = false
          lambda_arn   = data.terraform_remote_state.shared.outputs.module_lambda_at_edge_01_lambda_function_qualified_arn
        }
        origin-request = {
          include_body = false
          lambda_arn = module.lambda_at_edge_01.lambda_function_qualified_arn
        }
        origin-response = {
          include_body  = false
          lambda_arn    = data.terraform_remote_state.shared.outputs.module_lambda_at_edge_02_lambda_function_qualified_arn 
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

    # realtime_log_config_arn = aws_cloudfront_realtime_log_config.cf_realtime_log_config_01.arn

    /* function_association = {
      # Valid keys: viewer-request, viewer-response
      viewer-request = {
        function_arn = data.terraform_remote_state.shared.outputs.aws_cloudfront_function_cf_function_01_arn
      }
    } */
    
    lambda_function_association = {
      viewer-request = {
        include_body = false
        lambda_arn   = data.terraform_remote_state.shared.outputs.module_lambda_at_edge_01_lambda_function_qualified_arn
      }
      origin-request = {
        include_body = false
        lambda_arn = module.lambda_at_edge_01.lambda_function_qualified_arn
      }
      origin-response = {
        include_body  = false
        lambda_arn    = data.terraform_remote_state.shared.outputs.module_lambda_at_edge_02_lambda_function_qualified_arn 
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

## LAMBDA ##

data "archive_file" "archive_01" {
  type        = "zip"
  source_file = "${path.module}/lambda-originReq-S3.mjs"
  output_path = "${path.module}/lambda-originReq-S3.mjs.zip"
}

/* data "archive_file" "archive_02" {
  type        = "zip"
  source_file = "${path.module}/lambda-transformCloudfrontAccessLogs.py"
  output_path = "${path.module}/lambda-transformCloudfrontAccessLogs.py.zip"
} */

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
  function_name = "originReq-S3-jlv6-production"
  description   = "Sets host header value to Production S3_bucket when CloudFront origin request to S3.origin"
  handler       = "lambda-originReq-S3.handler"
  runtime       = "nodejs20.x"

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn
  
  use_existing_cloudwatch_log_group  = true
  attach_cloudwatch_logs_policy      = false
  attach_create_log_group_permission = false
  logging_log_group                  = module.cw_logs_01.log_group_name
}

/* module "lambda_01" {
  depends_on = [
    data.archive_file.archive_02,
    module.cw_logs_02
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
  function_name = "transformCloudfrontAccessLogs-jlv6-production"
  description   = "Transform CloudFront (Access) logs into a format suitable for ingestion and analysis in OpenObserve"
  handler       = "lambda-transformCloudfrontAccessLogs.handler"
  runtime       = "python3.13"

  create_role   = false
  lambda_role   = aws_iam_role.iam_role_01.arn
  
  use_existing_cloudwatch_log_group  = true
  attach_cloudwatch_logs_policy      = false
  attach_create_log_group_permission = false
  logging_log_group                  = module.cw_logs_02.log_group_name
} */

## KINESIS ##

/* resource "aws_kinesis_stream" "kinesis_stream_01" {
  provider         = aws.us_east_1
  name             = "cf-logs-jlv6-production"
  shard_count      = 1
  retention_period = 48

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
} */

/* resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream_01" {
  provider    = aws.us_east_1
  depends_on = [
    aws_iam_role.iam_role_03,
    aws_kinesis_stream.kinesis_stream_01,
    module.lambda_01
  ]
  name        = "cf-logs-jlv6-production"
  destination = "http_endpoint"

  kinesis_source_configuration {
    role_arn           = aws_iam_role.iam_role_03.arn
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream_01.arn
  }

  http_endpoint_configuration {
    url                = "${var.OPENOBSERVE_URI}/aws/default/cloudwatch_metrics/_kinesis_firehose"
    name               = "OpenObserve instance on Pluto"
    access_key         = "${var.OPENOBSERVE_KINESIS_FIREHOSE_ACCESS_KEY}"
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.iam_role_03.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.iam_role_03.arn
      bucket_arn         = module.s3_bucket_03.s3_bucket_arn
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.lambda_01.lambda_function_qualified_arn}"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "3"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "45"
        }
      }
    }
    request_configuration {
      content_encoding = "NONE"  # Can be NONE, GZIP, or other formats
    }
  }
} */