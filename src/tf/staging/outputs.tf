#S3
output "module_s3_bucket_01_s3_bucket_id" {
  description = "The name of S3 bucket 01"
  value = try(module.s3_bucket_01.s3_bucket_id, "")
}

#ACM
output "aws_acm_certificate_cert01_arn" {
  description = "The ARN of the ACM Certificate."
  value       = try(aws_acm_certificate.cert01.arn, "")
}
