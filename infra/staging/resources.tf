data "aws_acm_certificate" "this" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

module "ecs" {
  source = "../modules/ecs"

  vpc_id      = module.vpc.vpc_id
  name        = var.name
  tags        = var.tags
  environment = var.environment

  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.this.arn
  default_tg_arn  = module.server-api-1.tg_arn
}

module "vpc" {
  source = "../modules/network"

  name        = var.name
  tags        = var.tags
  environment = var.environment
}

module "sqs" {
  source = "../modules/sqs"

  name = "${var.name}"
  tags = "${var.tags}"
  environment = "${var.environment}"

  env_api_url = var.api_url
}

module "cicd-api-1" {
  source = "../modules/cicd"

  name        = var.name
  tags        = var.tags
  environment = var.environment
  server-name = "api-1"
  project-name = var.name
}


module "cicd-api-2" {
  source = "../modules/cicd"

  name        = var.name
  tags        = var.tags
  environment = var.environment
  server-name = "api-2"
  project-name = var.name
}

resource "aws_s3_bucket" "domain_bucket" {
  bucket = "${var.name}-domain-${var.environment}"
}

module "server-api-1" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name      = "api-1"
  alb_listener_arn = module.ecs.alb_listener_arn
  container_image  = "${module.cicd-api-1.repository_url}:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster_id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_id

  env_database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-1"
  env_queue_url = module.sqs.queue_url
  env_bucket_name = aws_s3_bucket.domain_bucket.bucket_domain_name
}

module "server-api-2" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name      = "api-2"
  alb_listener_arn = module.ecs.alb_listener_arn
  container_image  = "${module.cicd-api-2.repository_url}:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster_id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_id

  env_database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-2"
}

module "db" {
  source = "../modules/db"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids[*]
  db_password       = var.db_password
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = module.db.rds_hostname
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.db.rds_port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = module.db.rds_username
}
