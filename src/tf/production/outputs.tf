# S3
output "s3_bucket_prod01_id" {
  description = "The name of the bucket."
  value       = try(aws_s3_bucket_policy.prod01.id, aws_s3_bucket.prod01.id, "")
}

output "s3_bucket_prod01_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = try(aws_s3_bucket.prod01.arn, "")
}

output "s3_bucket_prod01_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = try(aws_s3_bucket.prod01.bucket_domain_name, "")
}

output "s3_bucket_prod01_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = try(aws_s3_bucket.prod01.bucket_regional_domain_name, "")
}

output "s3_bucket_prod01_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for prod01 bucket's region."
  value       = try(aws_s3_bucket.prod01.hosted_zone_id, "")
}

output "s3_bucket_prod01_policy" {
  description = "The policy of the bucket, if the bucket is configured with a policy. If not, will be an empty string."
  value       = try(aws_s3_bucket_policy.prod01.policy, "")
}

output "s3_bucket_prod01_region" {
  description = "The AWS region prod01 bucket resides in."
  value       = try(aws_s3_bucket.prod01.region, "")
}

output "s3_bucket_prod01_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, will be an empty string."
  value       = try(aws_s3_bucket_website_configuration.prod01.website_endpoint, "")
}

output "s3_bucket_prod01_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, will be an empty string. This is used to create Route 53 alias records."
  value       = try(aws_s3_bucket_website_configuration.prod01.website_domain, "")
}

#ACM
output "
