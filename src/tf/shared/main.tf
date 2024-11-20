## ACM ##
resource "aws_acm_certificate" "cert01" {
  provider = aws.us_east_1
  private_key=file("privkey.pem")
  certificate_body = file("cert.pem")
  certificate_chain=file("fullchain.pem")
}

## CLOUDFRONT ##

resource "aws_cloudfront_function" "cf_function_01" {
  # https://www.andrlik.org/dispatches/til-block-ai-bots-cloudfront-function/
  provider = aws.us_east_1
  name     = "block-ai-crawler"
  comment  = "Block AI crawler user-agents"
  runtime  = "cloudfront-js-2.0"
  code     = file("${path.module}/cf-function-block-ai-crawler.js")
  publish  = true
}