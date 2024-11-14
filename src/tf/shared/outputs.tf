## ACM ##

output "aws_acm_certificate_cert01_arn" {
  description = "The ARN of the ACM Certificate."
  value       = aws_acm_certificate.cert01.arn
}
