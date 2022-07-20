resource "aws_ecs_task_definition" "this" {
  network_mode             = "awsvpc"
  family                   = "${var.name}-td-${var.server-name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf
  task_role_arn            = aws_iam_role.ecs_task_role.arn           # to access AWS Services
  container_definitions = jsonencode([
    {
      name      = "${var.name}"
      image     = "${var.container_image}"
      logConfiguration = {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region" : "us-east-1",
                "awslogs-group" : "stream-to-log-fluentd",
                "awslogs-stream-prefix" : "${var.name}"
            }
        },
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = "${var.container_port}"
          hostPort      = "${var.container_port}"
        }
      ]
    }
  ])

  tags = var.tags
}


resource "aws_security_group" "ecs_security_group" {
  name   = "${var.name}-ecs-sg-${var.server-name}-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "SSH inbound"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name                               = "${var.name}-${var.server-name}-${var.environment}"
  launch_type                        = "FARGATE"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_security_group.id]
    subnets          = [var.subnet_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this.arn
    container_name   = "${var.name}"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = var.tags
}