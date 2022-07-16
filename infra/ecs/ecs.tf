resource "aws_ecs_cluster" "main" {
  name = "${var.name}-ecs-cluster-${var.environment}"
}

resource "aws_security_group" "ecs_security_group" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP inbound"
    from_port   = 3008
    to_port     = 3008
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

  # ingress {
  #   description = "ALB"
  #   from_port   = 31000
  #   to_port     = 61000
  #   protocol    = "tcp"
  # }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 1
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_ecs_task_definition" "api-1-td" {
  network_mode             = "awsvpc"
  family                   = "api-1-td"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf
  task_role_arn            = aws_iam_role.ecs_task_role.arn           # to access AWS Services
  container_definitions = jsonencode([
    {
      name        = "api-1"
      image       = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc/api-1:latest"
      essential   = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 3008
          hostPort      = 3008
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "api-1" {
  name                               = "api-1"
  launch_type                        = "FARGATE"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.api-1-td.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_security_group.arn]
    subnets          = [aws_subnet.public.id, aws_subnet.private.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.api-1.arn
    container_name   = "api-1"
    container_port   = 3008
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}