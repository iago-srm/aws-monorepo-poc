resource "aws_db_subnet_group" "this" {
  name       = "main"
  subnet_ids = var.public_subnet_ids

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  name   = "main"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_security_group" "pgsecgrp" {
  name        = "pgsecgrp"
  description = "Allow inbound traffic for PG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "PG connection"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier             = "main"
  instance_class         = "db.t3.micro"
  apply_immediately = true
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.4"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.pgsecgrp.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = var.tags
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.this.username
}