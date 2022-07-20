resource "aws_alb_listener" "http" {
  load_balancer_arn = var.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
  # default_action {
  #   type = "redirect"

  #   redirect {
  #     port        = 443
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }

  tags = var.tags
}

# resource "aws_alb_listener" "https" {
#   load_balancer_arn = var.alb_arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn = var.acm_validation_arn

#   default_action {
#     target_group_arn = aws_alb_target_group.this.arn
#     type             = "forward"
#   }
  
#   tags = var.tags
# }
