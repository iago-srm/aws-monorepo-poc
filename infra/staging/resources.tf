module "ecs" {
  source = "../modules/ecs"

  vpc_id      = module.vpc.vpc_id
  name        = var.name
  tags        = var.tags
  environment = var.environment

  public_subnet_ids = module.vpc.public_subnet_ids
  # domain_name       = "isrm.link"
  # subdomain_name    = "api.language-app"
  certificate_arn = "arn:aws:acm:us-east-1:553239741950:certificate/87be9d27-ad1f-47f1-ad2d-aabbe95d4e6a"
  default_tg_arn  = module.server-api-1.tg_arn
}

module "vpc" {
  source = "../modules/network"

  name        = var.name
  tags        = var.tags
  environment = var.environment
}

# module "sqs" {
#   source = "./sqs"

#   name = "${var.name}"
#   tags = "${var.tags}"
#   environment = "${var.environment}"
# }

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

module "server-api-1" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name      = "api-1"
  alb_listener_arn = module.ecs.alb_listener_arn
  container_image  = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc/api-1:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster_id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_id
}

module "server-api-2" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name      = "api-2"
  alb_listener_arn = module.ecs.alb_listener_arn
  container_image  = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc/api-2:latest"
  alb_id           = module.ecs.alb.id
  cluster_id       = module.ecs.cluster_id
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnet_id
}

module "db" {
  source = "../modules/db"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids[*]
  db_password       = "supersecret"
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