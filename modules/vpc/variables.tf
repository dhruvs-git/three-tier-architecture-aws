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

variable "availability_zone" {
  description = "List of availability zones to deploy subnets into"
  type = list(string)
}

variable "project_name" {
  description = "prefix for all resources"
  type = string
}
