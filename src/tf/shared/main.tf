## ACM
resource "aws_acm_certificate" "cert01" {
  provider = aws.${var.AWS_REGION_01}
  private_key=file("privkey.pem")
  certificate_body = file("cert.pem")
  certificate_chain=file("fullchain.pem")
}
