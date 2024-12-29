resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "${var.environment}-redis-sg"
  description = "Security group for Redis cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = var.cluster_name
  replication_group_description = "Redis cluster for ${var.environment}"
  node_type                    = var.instance_type
  port                         = 6379
  parameter_group_family       = "redis6.x"
  automatic_failover_enabled   = true
  multi_az_enabled            = true
  num_cache_clusters          = 2

  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  maintenance_window         = "sun:05:00-sun:06:00"
  snapshot_window           = "03:00-04:00"
  snapshot_retention_limit  = 7

  tags = {
    Environment = var.environment
  }
}

# Store Redis connection info in Secrets Manager
resource "aws_secretsmanager_secret" "redis_credentials" {
  name = "${var.environment}/redis/credentials"
}

resource "aws_secretsmanager_secret_version" "redis_credentials" {
  secret_id = aws_secretsmanager_secret.redis_credentials.id
  secret_string = jsonencode({
    host = aws_elasticache_replication_group.main.primary_endpoint_address
    port = aws_elasticache_replication_group.main.port
  })
}
