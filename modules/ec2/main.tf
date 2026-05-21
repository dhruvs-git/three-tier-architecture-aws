# EC2 MODULE - MAIN

resource "aws_security_group" "ec2_sg" {
  name   = "${var.project_name}-ec2-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# Only allows inbound traffic from the ALB on port 3000
resource "aws_vpc_security_group_ingress_rule" "ec2_sg_from_alb" {
  security_group_id            = aws_security_group.ec2_sg.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
  referenced_security_group_id = var.alb_security_group_id
  // we can use either cidr_ipv4 argument or the one that we have used in the code
}

/* Allows all outbound traffic so EC2 can reach RDS, SSM endpoints,
   and the internet via NAT Gateway for package installs */
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



# IAM ROLE FOR SSM
# Allows EC2 to be accessed via AWS SSM Session Manager
# No SSH required, no port 22 open, no key pairs needed

# IAM role — defines that EC2 service is allowed to assume this role
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-ssm-role"
  }
}

# Attaches AWS managed SSM policy to the role - Permissions
resource "aws_iam_role_policy_attachment" "ec2_ssm_role" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile — the bridge between the IAM role and the EC2 instance
# EC2 cannot use an IAM role directly, it must be wrapped in an instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}




# EC2 INSTANCE

# Fetches the latest Amazon Linux 2023 AMI automatically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


# EC2 instance in private subnet — no public IP, not internet facing
# Accessed only via SSM Session Manager using the attached IAM role
resource "aws_instance" "ec2_app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = var.private_subnet_ids[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # templatefile() substitutes ${db_host}, ${db_name} etc. into the script
  # file() would silently ignore all variables — the app would never know the DB endpoint
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    db_host     = var.db_host
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })

  # Ensures the SSM policy is fully attached before EC2 launches
  # Without this, SSM agent starts without permissions and fails to register
  depends_on = [aws_iam_role_policy_attachment.ec2_ssm_role]

  tags = {
    Name = "${var.project_name}-ec2-app"
  }
}


# TARGET GROUP REGISTRATION

# Registers this EC2 instance into the ALB target group
# Port 3000 must match the target group port and app port:
# ALB listener (80) → target group (3000) → EC2 app (3000)
resource "aws_lb_target_group_attachment" "ec2_app" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.ec2_app.id
  port             = 3000
}

