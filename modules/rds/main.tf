# RDS MODULE - MAIN


resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic only from RDS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Only allows inbound MySQL traffic from EC2 on port 3306
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id            = aws_security_group.rds_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
  referenced_security_group_id = var.ec2_security_group_id
}

# No egress rule needed — RDS only responds, never initiates connections

# DB SUBNET GROUP


# AWS requires a subnet group before placing an RDS instance
# Unlike EC2, RDS cannot be placed directly into a subnet
# At least 2 subnets in different AZs required even for single-AZ
resource "aws_db_subnet_group" "db_subnet_grp" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}


# RDS INSTANCE


resource "aws_db_instance" "rds_db" {

  identifier           = "${var.project_name}-rds-database"
  allocated_storage    = 20 # Minimum storage for MySQL on AWS in GB
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"

  # Credentials defined at root level
  # Same values passed to EC2 module for app DB connection
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Places RDS into the private subnet group
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_grp.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az            = false # No multi-AZ for this project - but remember Multi-AZ very IMP
  publicly_accessible = false # No public-IP

  # Set to false in production to protect data
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-database"
  }
}


