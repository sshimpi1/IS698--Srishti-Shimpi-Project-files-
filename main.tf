terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# ------------------ VPC ------------------
resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "Project_VPC_Srishti"
    Owner = "Srishti"
  }
}

# ------------------ Subnets ------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-1a-srishti" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-1b-srishti" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "private-subnet-1a-srishti" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "private-subnet-1b-srishti" }
}

# ------------------ Internet Gateway + Routes ------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id
  tags   = { Name = "srishti-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "srishti-public-rt" }
}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.project_vpc.id
  tags   = { Name = "srishti-private-rt" }
}

resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# ------------------ Security Groups ------------------

# ALB SG
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-srishti"
  description = "ALB SG allows HTTP from internet"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg-srishti" }
}

# Web EC2 SG
resource "aws_security_group" "web_sg" {
  name        = "web-sg-srishti"
  description = "Web EC2 SG"
  vpc_id      = aws_vpc.project_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # lock to your IP in real life
  }

  # HTTP from ALB only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg-srishti" }
}

# DB SG
resource "aws_security_group" "db_sg" {
  name        = "db-sg-srishti"
  description = "RDS MySQL SG"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "db-sg-srishti" }
}

# ------------------ Outputs ------------------
output "vpc_id"              { value = aws_vpc.project_vpc.id }
output "public_subnet_1_id"  { value = aws_subnet.public_1.id }
output "public_subnet_2_id"  { value = aws_subnet.public_2.id }
output "private_subnet_1_id" { value = aws_subnet.private_1.id }
output "private_subnet_2_id" { value = aws_subnet.private_2.id }
output "alb_sg_id"           { value = aws_security_group.alb_sg.id }
output "web_sg_id"           { value = aws_security_group.web_sg.id }
output "db_sg_id"            { value = aws_security_group.db_sg.id }