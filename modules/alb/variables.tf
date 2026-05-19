# ALB MODULE - VARIABLES

variable "project_name" {
  description = "name prefix for all resources"
  type        = string
}

# Needed to attach the ALB security group to the correct VPC
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# ALB is placed across these subnets for high availability
# Must be public subnets — ALB needs to receive internet traffic
# Receives module.vpc.public_subnet_ids from root module
variable "public_subnet_ids" {
  description = "The list of public subnets IDs for the ALB"
  type        = list(string)
}

