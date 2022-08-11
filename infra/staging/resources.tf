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
  default_tg_arn  = module.server-api-1.tg_green.arn
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
  git_repo = var.github_repo

  tg_green_name = module.server-api-1.tg_green.name
  tg_blue_name = module.server-api-1.tg_blue.name
  ecs_cluster_name = module.ecs.cluster.name
  ecs_service_name = module.server-api-1.ecs_service.name
  alb_listener_http_arn = module.ecs.alb_listener_http_arn
  alb_listener_https_arn = module.ecs.alb_listener_https_arn
}


module "cicd-api-2" {
  source = "../modules/cicd"

  name        = var.name
  tags        = var.tags
  environment = var.environment
  server-name = "api-2"
  git_repo = var.github_repo

  tg_green_name = module.server-api-1.tg_green.name
  tg_blue_name = module.server-api-1.tg_blue.name
  ecs_cluster_name = module.ecs.cluster.name
  ecs_service_name = module.server-api-2.ecs_service.name
  alb_listener_http_arn = module.ecs.alb_listener_http_arn
  alb_listener_https_arn = module.ecs.alb_listener_https_arn
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
  alb_listener_arn = module.ecs.alb_listener_https_arn
  container_image  = "${module.cicd-api-1.repository_url}:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster.id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_ids[0]

  env_database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-1"
  env_queue_url = module.sqs.queue_url
  env_bucket_name = aws_s3_bucket.domain_bucket.bucket
}

module "server-api-2" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name      = "api-2"
  alb_listener_arn = module.ecs.alb_listener_https_arn
  container_image  = "${module.cicd-api-2.repository_url}:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster.id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_ids[0]

  env_database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-2"
}

module "db" {
  source = "../modules/db"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  # public_subnet_ids = module.vpc.public_subnet_ids[*]
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password       = var.db_password
}

module "bastion" {
  source = "../modules/bastion"
  
  tags        = var.tags
  vpc_id = module.vpc.vpc_id
  allowed_ip = var.admin_ip
  db_id = module.db.rds_id
  subnet_id = module.vpc.public_subnet_ids[0]
  key_pair_name = var.key_pair_name

  database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-2"
}

