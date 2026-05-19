# -------------------------------------------------------
# VPC MODULE - MAIN
# Creates the entire network layer:
# VPC, subnets, IGW, NAT Gateway, and route tables
# -------------------------------------------------------


# Creating the VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.project_name} - vpc"
  }
}


# Creating IGW - Allows public subnets to send and receive traffic from the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name} - igw"
  }
}


# Public subnets - Used by ALB and NAT gateway
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-Public-subnet-${count.index + 1}"
  }
}


# Private subnets - Used by ec2 and RDS
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.project_name}-Private-subnet-${count.index + 1}"
  }

}


# -------------------------------------------------------
# PUBLIC ROUTING
# Routes public subnet traffic to the internet via IGW
# -------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route — all outbound traffic goes to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-Public-rt"
  }
}

# Attaches the public route table to each public subnet
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# -------------------------------------------------------
# NAT GATEWAY
# Allows private subnet resources to reach the internet
# outbound only — nothing from internet can reach them
# -------------------------------------------------------

# Elastic IP — static public IP assigned to the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT gateway in public subnet 
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  # depends_on ensures IGW exists before NAT Gateway is created
  depends_on = [aws_internet_gateway.igw]
}


# -------------------------------------------------------
# PRIVATE ROUTING
# Routes private subnet traffic to the internet via NAT
# -------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Default route — all outbound traffic goes to NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}


# Attaches the private route table to each private subnet
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


