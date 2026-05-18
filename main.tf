module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  cidr_block = var.cidr_block
  availability_zone = var.availability_zone
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
}


module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}


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


module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn
  db_host = module.rds.db_host
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}



