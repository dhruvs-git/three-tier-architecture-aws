variable "project_name" {
  description = "The prefix for all resources"
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The ID of alb security group for ec2 reference"
  type = string
}

variable "target_group_arn" {
  description = "The alb target group arn for ec2 to get registered "
}

variable "db_host" {
  description = "The RDS endpoint address"
  type = string
}

variable "db_name" {
  description = "The name for the database"
  type = string
}

variable "db_username" {
  description = "the database username"
  type = string
}

variable "db_password" {
  description = "The database password"
  type = string
  sensitive = true
}
