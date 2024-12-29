provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
  environment = "production"
  vpc_cidr = "10.0.0.0/16"
  cluster_name = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"
  environment = "production"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_groups = {
    general = {
      desired_size = 3
      min_size     = 3
      max_size     = 10
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

module "ecr" {
  source = "../../modules/ecr"
  environment = "production"
  repository_names = [
    "api-gateway",
    "products-service",
    "orders-service",
    "users-service"
  ]
}

module "redis" {
  source = "../../modules/redis"
  environment = "production"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_type = "cache.t3.medium"
  num_cache_nodes = 3
  multi_az_enabled = true
  allowed_security_groups = [module.eks.node_security_group_id]
}

module "postgres" {
  source = "../../modules/rds"
  environment = "production"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  instance_class = "db.t3.large"
  allocated_storage = 100
  engine = "postgres"
  engine_version = "14"
  database_name = "ecommerce"
  multi_az = true
  backup_retention_period = 7
  allowed_security_groups = [module.eks.node_security_group_id]
}

module "mongodb" {
  source = "../../modules/mongodb"
  environment = "production"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  instance_class = "db.r5.large"
  instance_count = 3
  master_username = var.mongodb_username
  master_password = var.mongodb_password
  allowed_security_groups = [module.eks.node_security_group_id]
}

module "monitoring" {
  source = "../../modules/monitoring"
  environment = "production"
  cluster_name = var.cluster_name
  enable_prometheus = true
  enable_grafana = true
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  retention_days = 30
}
