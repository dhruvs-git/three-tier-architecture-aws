# ROOT MODULE - OUTPUTS

output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}

# We will use this after terraform apply to test the application
output "alb_dns_name" {
  description = "The DNS for the alb - use this to access the application"
 value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "The RDS instance endpoint"
  value = module.rds.db_host
}