variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where MongoDB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for MongoDB"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class for MongoDB nodes"
  type        = string
}

variable "instance_count" {
  description = "Number of MongoDB instances"
  type        = number
}

variable "master_username" {
  description = "MongoDB master username"
  type        = string
}

variable "master_password" {
  description = "MongoDB master password"
  type        = string
  sensitive   = true
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to connect to MongoDB"
  type        = list(string)
}
