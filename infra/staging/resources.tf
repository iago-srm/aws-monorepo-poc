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
  default_tg_arn  = module.server["api-1"].tg_green.arn
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

module "cicd-pipeline" {
  source = "../modules/cicd"

  for_each = toset(var.microsservices)
  name = "cicd-pipeline-${each.key}-${var.environment}"

  tags        = var.tags
  project-name = var.name
  server-name = each.key
  git_repo = var.github_repo

  # tg_green_name = module.server[each.key].tg_green.name
  # tg_blue_name = module.server[each.key].tg_blue.name
  ecs_cluster_name = module.ecs.cluster.name
  # ecs_service_name = module.server[each.key].ecs_service.name
  alb_listener_http_arn = module.ecs.alb_listener_http_arn
  alb_listener_https_arn = module.ecs.alb_listener_https_arn
}

resource "aws_s3_bucket" "domain_bucket" {
  bucket = "${var.name}-domain-${var.environment}"
}

module "server" {
  source = "../modules/server"

  for_each = toset(var.microsservices)

  name        = "server-${each.key}"
  tags        = var.tags
  environment = var.environment

  server-name      = each.key
  alb_listener_arn = module.ecs.alb_listener_https_arn
  container_image  = "${module.cicd-pipeline[each.key].repository_url}:latest"
  # container_image = ""
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster.id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_ids[0]

  env_database_url = "postgres://${module.db.rds_username}:${module.db.rds_password}@${module.db.rds_hostname}:${module.db.rds_port}/api-1"
  env_queue_url = module.sqs.queue_url
  env_bucket_name = aws_s3_bucket.domain_bucket.bucket
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

