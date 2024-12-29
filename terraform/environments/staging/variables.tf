variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"  # Default value if not specified
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true  # Marks as sensitive, won't show in logs
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Redis auth password"
  type        = string
  sensitive   = true
}
