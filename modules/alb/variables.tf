variable "project_name" {
  description = "name prefix for all resources"
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "public_subnet_ids" {
  description = "The list of public subnets IDs for the ALB"
  type = list(string)
}

