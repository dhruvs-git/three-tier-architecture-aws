resource "aws_security_group" "ec2_sg" {
  name = "${var.project_name}-ec2-sg"
  vpc_id = var.vpc_id 

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_from_alb" {
  security_group_id = aws_security_group.ec2_sg.id
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
  referenced_security_group_id = var.alb_security_group_id
  // we can use either cidr_ipv4 argument or the one that we have used in the code
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}


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

resource "aws_iam_role_policy_attachment" "ec2_ssm_role" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


// ec2 will get the latest ami
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


resource "aws_instance" "ec2_app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id = var.private_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = file("${path.module}/scripts/user_data.sh")


  tags = {
    Name = "${var.project_name}-ec2-app"
  }
}


  resource "aws_lb_target_group_attachment" "ec2_app" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.ec2_app.id
  port             = 3000
}

