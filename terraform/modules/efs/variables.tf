variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EFS will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access EFS"
  type        = list(string)
}
