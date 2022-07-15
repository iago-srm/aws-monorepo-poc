
# resource "aws_s3_bucket_policy" "default" {
#   bucket = aws_s3_bucket.ecs_alb_logs_bucket.id
#   policy = data.aws_iam_policy_document.default.json
# }
# data "aws_elb_service_account" "default" {}
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
# data "aws_iam_policy_document" "default" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = [data.aws_elb_service_account.default.arn]
#     }

#     actions = [
#       "s3:PutObject",
#     ]

#     resources = [
#       aws_s3_bucket.ecs_alb_logs_bucket.arn
#     ]
#   }
# }

# resource "aws_s3_bucket" "ecs_alb_logs_bucket" {
#   tags   = var.tags
# }

resource "aws_lb" "alb" {
  name               = "ecs-alb"
  internal           = false #equivalent to scheme=internet-facing
  load_balancer_type = "application"
  idle_timeout       = 30
  security_groups    = [aws_security_group.ecs_security_group.id]
  subnets            = [aws_subnet.public_one.id, aws_subnet.public_two.id]

  enable_deletion_protection = true

  #   access_logs {
  #     bucket  = aws_s3_bucket.ecs_alb_logs_bucket.bucket
  #     prefix  = "ecs-alb"
  #     enabled = true
  #   }

  tags = var.tags
}


resource "aws_lb_target_group" "alb_tg" {
  name     = "api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 6
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}