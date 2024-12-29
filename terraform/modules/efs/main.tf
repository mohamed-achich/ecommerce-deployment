resource "aws_efs_file_system" "main" {
  creation_token = "efs-${var.environment}"
  encrypted      = true

  tags = {
    Name        = "efs-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "efs-${var.environment}"
  description = "Allow inbound NFS traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from EKS nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "efs-${var.environment}"
    Environment = var.environment
  }
}

# Create a storage class for EFS
resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.main.id
    directoryPerms   = "700"
  }
}
