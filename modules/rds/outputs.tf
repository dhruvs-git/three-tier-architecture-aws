output "db_host" {
  description = "The RDS endpoint address"
  value = aws_db_instance.rds_db.address
}

