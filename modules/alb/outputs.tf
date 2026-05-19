# ALB MODULE - OUTPUTS

/* Used by EC2 module ingress rule — only allows traffic
   from the ALB security group, not from anywhere else */
output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

# Printed after terraform apply — We will use this URL to test the app
output "alb_dns_name" {
  description = "The dns for the alb"
  value       = aws_lb.main.dns_name
}

/* Used by EC2 module to register the instance into the target group
   Without this the ALB has no EC2 instance to forward traffic to */
output "target_group_arn" {
  description = "arn for the target group"
  value       = aws_lb_target_group.main.arn
}



