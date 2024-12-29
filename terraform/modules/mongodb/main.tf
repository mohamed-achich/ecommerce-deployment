resource "aws_docdb_cluster" "mongodb" {
  cluster_identifier      = "docdb-${var.environment}"
  engine                 = "docdb"
  master_username        = var.master_username
  master_password        = var.master_password
  backup_retention_period = var.environment == "production" ? 7 : 1
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = var.environment != "production"
  vpc_security_group_ids  = [aws_security_group.mongodb.id]
  db_subnet_group_name    = aws_docdb_subnet_group.mongodb.name

  tags = {
    Environment = var.environment
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "docdb-${var.environment}-${count.index}"
  cluster_identifier = aws_docdb_cluster.mongodb.id
  instance_class     = var.instance_class
}

resource "aws_docdb_subnet_group" "mongodb" {
  name       = "docdb-${var.environment}"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "mongodb" {
  name        = "docdb-${var.environment}"
  description = "Security group for DocumentDB cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  tags = {
    Environment = var.environment
  }
}
