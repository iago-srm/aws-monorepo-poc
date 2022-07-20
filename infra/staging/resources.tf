module "ecs" {
  source = "../modules/ecs"

  vpc_id      = module.vpc.vpc_id
  name        = var.name
  tags        = var.tags
  environment = var.environment

  subnet_ids = module.vpc.public_subnet_ids
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
}


module "cicd-api-2" {
  source = "../modules/cicd"

  name        = var.name
  tags        = var.tags
  environment = var.environment
  server-name = "api-2"
}

module "server-api-1" {
  source = "../modules/server"

  name        = var.name
  tags        = var.tags
  environment = var.environment

  server-name        = "api-1"
  # acm_validation_arn = module.ecs.acm_validation_arn
  alb_arn            = module.ecs.alb.arn
  container_image    = "553239741950.dkr.ecr.us-east-1.amazonaws.com/aws-monorepo-poc/api-1:latest"
  alb_id             = module.ecs.alb.id
  cluster_id         = module.ecs.cluster_id
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.private_subnet_id
}