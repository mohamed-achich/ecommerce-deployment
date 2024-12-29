provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
  environment = "staging"
  vpc_cidr = "10.0.0.0/16"
  cluster_name = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"
  environment = "staging"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_groups = {
    general = {
      desired_size = 2
      min_size     = 2
      max_size     = 3
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"  # Using spot instances for staging
    }
  }
}

module "ecr" {
  source = "../../modules/ecr"
  environment = "staging"
  repository_names = [
    "api-gateway",
    "products-service",
    "orders-service",
    "users-service"
  ]
}

module "efs" {
  source = "../../modules/efs"
  environment = "staging"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_security_groups = [module.eks.node_security_group_id]
}

module "monitoring" {
  source = "../../modules/monitoring"
  environment = "staging"
  cluster_name = var.cluster_name
  enable_prometheus = true
  enable_grafana = true
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
