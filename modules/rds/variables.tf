variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}

variable "vpc_id" {
  description = "The ID of the vpc"
  type = string
}

variable "private_subnet_ids" {
  description = "The ID of the private subnet for rds"
  type = list(string)
}

variable "ec2_security_group_id" {
  description = "The ID of the ec2 sg for RDS"
  type = string
}

variable "db_name" {
  description = "The name of the db"
  type = string
}

variable "db_username" {
  description = "The database username"
  type = string
}

variable "db_password" {
  description = "The password for the database"
  type = string
  sensitive = true
}


