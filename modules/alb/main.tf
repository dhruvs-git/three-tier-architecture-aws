# -------------------------------------------------------
# ALB MODULE
# Creates the web tier:
# Security group, ALB, target group, and HTTP listener
# -------------------------------------------------------


# Creating SG for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Allows inbound HTTP traffic from anywhere on port 80
resource "aws_vpc_security_group_ingress_rule" "alb_inbound" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Allows all outbound traffic so ALB can forward requests to EC2
resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# External ALB in public subnets — receives internet traffic on port 80
# internal = false makes it publicly accessible
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Environment = "${var.project_name}-alb"
  }
}


# Target group points to EC2 on port 3000 — where app listens
/* 
  Protocol must match end to end:
  ALB listener (HTTP:80) → target group (HTTP:3000) → EC2 Express app (port 3000) 
*/
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Performing Health checks on ec2 every 30 seconds
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }

}


# Listener on port 80 — connects the ALB to the target group
# Without this the ALB has no instruction for what to do with incoming traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}


