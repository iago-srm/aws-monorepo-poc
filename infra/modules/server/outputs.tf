output "tg_green" {
  value = aws_alb_target_group.green
}

output "tg_blue" {
  value = aws_alb_target_group.blue
}

output "ecs_service" {
  value = aws_ecs_service.this
}