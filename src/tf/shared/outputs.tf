## ACM ##

output "aws_acm_certificate_cert01_arn" {
  description = "The ARN of the ACM Certificate."
  value       = try(aws_acm_certificate.cert01.arn, "")
}

## CLOUDFRONT ##

output "aws_cloudfront_function_cf_function_01_arn" {
  description = "The ARN of CloudFront function 01."
  value       = try(aws_cloudfront_function.cf_function_01.arn, "")
}