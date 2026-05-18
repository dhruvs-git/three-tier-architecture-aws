output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  description = "The dns for the alb"
  value = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "arn for the target group"
  value = aws_lb_target_group.main.arn
}



