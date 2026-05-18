output "ec2_security_group_id" {
  description = "The ID of the ec2 security group will use for RDS"
  value = aws_security_group.ec2_sg.id
}