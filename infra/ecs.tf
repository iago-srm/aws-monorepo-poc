resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs-cluster-${var.environment}"
}

resource "aws_security_group" "ecs_security_group" {

  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ALB"
    from_port   = 31000
    to_port     = 61000
    protocol    = "tcp"
  }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_ecs_task_definition" "api-1-td" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name  = "api-1"
      image = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc/api-1:v1"
      essential = true
      environment = "${var.environment}"
      portMappings = [
        {
          protocol = "tcp"
          containerPort = 3008
          hostPort      = 3008
        }
      ]
    }
  ])
}

resource "aws_alb_target_group" "api-1" {
  name        = "${var.name}-api-1-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/ping"
   unhealthy_threshold = "2"
  }
}

resource "aws_ecs_service" "api-1" {
  name            = "api-1"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api-1-td.arn
  desired_count   = 1
  scheduling_strategy                = "REPLICA"
  
  load_balancer {
    target_group_arn = aws_alb_target_group.api-1.arn
    container_name   = "api-1"
    container_port   = 8080
  }
  
  lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}