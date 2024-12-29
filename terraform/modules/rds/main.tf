resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
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

# Users Database
resource "aws_db_instance" "users" {
  identifier           = var.users_db.identifier
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = var.instance_class
  allocated_storage   = 20
  storage_encrypted   = true

  db_name  = var.users_db.name
  username = var.users_db.username
  password = random_password.users_db_password.result
  port     = var.users_db.port

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = false
  deletion_protection    = true

  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn

  tags = {
    Environment = var.environment
    Service     = "users"
  }
}

# Orders Database
resource "aws_db_instance" "orders" {
  identifier           = var.orders_db.identifier
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = var.instance_class
  allocated_storage   = 20
  storage_encrypted   = true

  db_name  = var.orders_db.name
  username = var.orders_db.username
  password = random_password.orders_db_password.result
  port     = var.orders_db.port

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = false
  deletion_protection    = true

  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn

  tags = {
    Environment = var.environment
    Service     = "orders"
  }
}

# Generate random passwords for databases
resource "random_password" "users_db_password" {
  length  = 16
  special = true
}

resource "random_password" "orders_db_password" {
  length  = 16
  special = true
}

# Store passwords in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.environment}/rds/credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    users_db = {
      username = aws_db_instance.users.username
      password = random_password.users_db_password.result
      host     = aws_db_instance.users.endpoint
      port     = aws_db_instance.users.port
      database = aws_db_instance.users.db_name
    }
    orders_db = {
      username = aws_db_instance.orders.username
      password = random_password.orders_db_password.result
      host     = aws_db_instance.orders.endpoint
      port     = aws_db_instance.orders.port
      database = aws_db_instance.orders.db_name
    }
  })
}

# IAM role for RDS monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring.name
}
