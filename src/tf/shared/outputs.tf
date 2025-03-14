## IAM ##

output "aws_iam_role_iam_role_01_arn" {
  description = "The ARN of the LambdaExecution role"
  value = try(aws_iam_role.iam_role_01.arn)
}

## S3 ##

output "module_s3_bucket_01_s3_bucket_bucket_domain_name" {
  description = "The name of the S3 log bucket for all Cloudfront distributions"
  value = try(module.s3_bucket_01.s3_bucket_bucket_domain_name, "")
}

## ACM ##

output "aws_acm_certificate_cert01_arn" {
  description = "The ARN of the ACM Certificate."
  value       = try(aws_acm_certificate.cert01.arn, "")
}

## CLOUDFRONT ##

output "module_cf_distribution_01_cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_domain_name, "")
}

output "module_cf_distribution_01_cloudfront_distribution_id" {
  description = "The name of Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_id, "")
}

output "module_cf_distribution_02_cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to Cloudfront distribution 01"
  value = try(module.cf_distribution_02.cloudfront_distribution_domain_name, "")
}

output "module_cf_distribution_02_cloudfront_distribution_id" {
  description = "The name of Cloudfront distribution 02"
  value = try(module.cf_distribution_02.cloudfront_distribution_id, "")
}

## LAMBDA ##

output "module_lambda_at_edge_01_lambda_function_qualified_arn" {
  description = "The qualified arn of lambda@edge function to ban AI crawler bots"
  value =  try(module.lambda_at_edge_01.lambda_function_qualified_arn, "")
}

output "module_lambda_at_edge_02_lambda_function_qualified_arn" {
  description = "The qualified arn of lambda@edge function to ship logs to OpenObserve"
  value =  try(module.lambda_at_edge_02.lambda_function_qualified_arn, "")
}