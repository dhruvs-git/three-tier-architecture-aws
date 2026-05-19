# RDS MODULE - VARIABLES

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

# Needed to attach the RDS security group to the correct VPC
variable "vpc_id" {
  description = "The ID of the vpc"
  type        = string
}

# RDS is placed in private subnets — no public access
variable "private_subnet_ids" {
  description = "The ID of the private subnet for rds"
  type        = list(string)
}

# Used in RDS ingress rule — only allows MySQL traffic from EC2
variable "ec2_security_group_id" {
  description = "The ID of the ec2 sg for RDS"
  type        = string
}

# Database credentials — defined once at root level
variable "db_name" {
  description = "The name of the db"
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}


