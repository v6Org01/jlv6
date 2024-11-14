#S3
output "module_s3_bucket_01_s3_bucket_id" {
  description = "The name of S3 bucket 01"
  value = try(module.s3_bucket_01.s3_bucket_id, "")
}