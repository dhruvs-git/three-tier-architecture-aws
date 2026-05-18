# ROOT MODULE - VARIABLES

variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}


# -------------------------------------------------------
# NETWORK VARIABLES
# Passed into the VPC module to build the network layer
# -------------------------------------------------------

variable "cidr_block" {
  description = "CIDR block for the vpc"
  type = string
}

# One CIDR per AZ — order must match availability_zones list
variable "public_subnet_cidrs" {
  description = "CIDR for the public subnets"
  type = list(string)
}

# One CIDR per AZ — order must match availability_zones list
variable "private_subnet_cidrs" {
  description = "CIDR for the private subnets"
  type = list(string)
}

# Must match the length and order of public and private subnet CIDR lists
variable "availability_zone" {
  description = "List of availability zones"
  type = list(string)
}


# -------------------------------------------------------
# DATABASE VARIABLES
# Passed into both RDS and EC2 modules with identical values
# RDS creates the database with these, EC2 app connects using these
# -------------------------------------------------------

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

# Passed into providers.tf to set the AWS deployment region
variable "region" {
  description = "region in which the resources will be deployed"
}