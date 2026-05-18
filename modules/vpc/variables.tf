# -------------------------------------------------------
# VPC MODULE - VARIABLES
# -------------------------------------------------------

variable "project_name" {
  description = "prefix for all resources"
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR block for public subnets"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type = list(string)
}

# Order matters — availability_zones[0] is where public_subnet_cidrs[0] gets created
# Both lists must have the same number of entries
variable "availability_zone" {
  description = "List of availability zones to deploy subnets into"
  type = list(string)
}


