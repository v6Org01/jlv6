## CLOUDFRONT ##

output "module_cf_distribution_01_cloudfront_distribution_arn" {
  description = "The arn of Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_arn, "")
}
output "module_cf_distribution_01_cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_domain_name, "")
}
output "module_cf_distribution_01_cloudfront_distribution_id" {
  description = "The name of Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_id, "")
}