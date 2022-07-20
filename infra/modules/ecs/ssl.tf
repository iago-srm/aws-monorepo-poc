# resource "aws_acm_certificate" "this" {
#   domain_name       = aws_lb.main.dns_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = var.tags
# }

# resource "aws_acm_certificate_validation" "this" {
#   certificate_arn = aws_acm_certificate.this.arn
# }

# output "acm_validation_arn" {
#   value = aws_acm_certificate.this.arn
# }