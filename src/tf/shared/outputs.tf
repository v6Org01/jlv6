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
output "module_cf_distribution_01_cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_domain_name, "")
}
output "module_cf_distribution_02_cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to Cloudfront distribution 01"
  value = try(module.cf_distribution_02.cloudfront_distribution_domain_name, "")
}