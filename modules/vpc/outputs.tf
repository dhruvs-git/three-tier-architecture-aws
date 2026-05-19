# -------------------------------------------------------
# VPC MODULE - OUTPUTS
# Exports values needed by the ALB, EC2, and RDS modules
# -------------------------------------------------------


/* Used by ALB, EC2, and RDS modules to attach
security groups and resources to the correct VPC */
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Used by the ALB module — ALB sits in public subnets
output "public_subnet_ids" {
  description = "List of public subnets IDs"
  value       = aws_subnet.public[*].id
}

# Used by EC2 and RDS modules — both sit in private subnets
output "private_subnet_ids" {
  description = "List of private subnets IDs"
  value       = aws_subnet.private[*].id
}

