variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the vpc"
  type = string
}

variable "public_subnet_cidrs" {
  description = "CIDR for the public subnets"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR for the private subnets"
  type = list(string)
}

variable "availability_zone" {
  description = "List of availability zones"
  type = list(string)
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

variable "region" {
  description = "region in which the resources will be deployed"
}