resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow traffic only from RDS"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.rds_sg.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
  referenced_security_group_id = var.ec2_security_group_id
}

/* there will be egress rule as db is a receiver and whatever that is allowed in 
   will get a response because of the stateful behavior of security groups */


resource "aws_db_subnet_group" "db_subnet_grp" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
}
}


resource "aws_db_instance" "rds_db" {
  
  identifier = "${var.project_name}-rds-database"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  parameter_group_name = "default.mysql8.0"
  
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name = aws_db_subnet_group.db_subnet_grp.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az = false
  publicly_accessible = false
  skip_final_snapshot  = true

  tags = {
    Name = "${var.project_name}-database"
  }
}


