## S3 ##

output "module_s3_bucket_01_s3_bucket_arn" {
  description = "The arn of S3 bucket 01"
  value = try(module.s3_bucket_01.s3_bucket_arn, "")
}

## CLOUDFRONT ##

output "module_cf_distribution_01_cloudfront_distribution_arn" {
  description = "The arn of Cloudfront distribution 01"
  value = try(module.cf_distribution_01.cloudfront_distribution_arn, "")
}