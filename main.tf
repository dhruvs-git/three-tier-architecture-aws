# ROOT MODULE - MAIN



# -------------------------------------------------------
# VPC MODULE
# Builds the entire network layer first — all other
# modules depend on its outputs
# -------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  cidr_block = var.cidr_block
  availability_zone = var.availability_zone
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
}


# -------------------------------------------------------
# ALB MODULE
# Depends on VPC outputs for subnet IDs and VPC ID
# -------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}


# -------------------------------------------------------
# RDS MODULE
# Depends on VPC outputs for subnets
# Depends on EC2 output for security group ingress rule
# -------------------------------------------------------
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.ec2_security_group_id
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}


# -------------------------------------------------------
# EC2 MODULE
# Depends on VPC, ALB, and RDS outputs
# -------------------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  # Private subnet IDs from VPC — EC2 sits in private subnets
  private_subnet_ids = module.vpc.private_subnet_ids
  # ALB sg ID — EC2 ingress rule only allows traffic from ALB
  alb_security_group_id = module.alb.alb_sg_id
  # Target group ARN — registers EC2 into ALB target group
  target_group_arn = module.alb.target_group_arn
  # RDS endpoint — passed into app as DB connection host
  db_host = module.rds.db_host
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}



