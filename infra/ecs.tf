resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "aws_security_group" "ecs_security_group" {
  # id = aws_vpc.main.id
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

resource "aws_launch_configuration" "container_instances" {
  name_prefix          = "aws-monorepo-poc-ecs-"
  image_id             = data.aws_ami.aws_optimized_ecs.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ecs_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data            = <<EOF
     #!/bin/bash -xe
    echo ECS_CLUSTER=${aws_ecs_cluster.main.id} >> /etc/ecs/ecs.config
    yum install -y aws-cfn-bootstrap
    /opt/aws/bin/cfn-signal -e $? --stack aws-monorepo-poc --resource ECSAutoScalingGroup --region us-east-1
    EOF
  #   lifecycle {
  #     create_before_destroy = true
  #   }
}

resource "aws_autoscaling_group" "ecs-asg" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  launch_configuration = aws_launch_configuration.container_instances.name
  vpc_zone_identifier  = [aws_subnet.public_one.id, aws_subnet.public_two.id]
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc:v1"
      # cpu       = 10
      # memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 0
        }
      ]
    },
    # {
    #   name      = "second"
    #   image     = "service-second"
    #   cpu       = 10
    #   memory    = 256
    #   essential = true
    #   portMappings = [
    #     {
    #       containerPort = 443
    #       hostPort      = 443
    #     }
    #   ]
    # }
  ])

  # volume {
  #   name      = "service-storage"
  #   host_path = "/ecs/service-storage"
  # }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  # }
}

resource "aws_ecs_service" "ec2" {
  name="api"
  launch_type = "EC2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs_service_role.arn
  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "api"
    container_port   = 8080
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}