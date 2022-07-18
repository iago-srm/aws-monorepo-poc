resource "aws_acm_certificate" "my_domain" {
  domain_name       = module.alb.alb_dns
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "alb-ssl" {
  certificate_arn = aws_acm_certificate.my_domain.arn
}