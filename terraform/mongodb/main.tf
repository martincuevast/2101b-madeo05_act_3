provider "aws" {
  region = "us-east-1"
}

# Crear una VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Crear una subnet en la VPC
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet2"
  }
}

# Security Group para las instancias EC2 (Incluye reglas de ingreso y salida)
resource "aws_security_group" "security_group" {
  name        = "instances_security_group"
  description = "Security Group para instancias EC2"
  vpc_id      = aws_vpc.main_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Reglas de salida (permitir todo el tráfico saliente)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance to Display Connection String (Primera instancia)
resource "aws_instance" "display_instance1" {
  ami           = "ami-0a11ab9d3b2792504"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id     = aws_subnet.subnet2.id

  tags = {
    Name = "Mongo-Instance"
  }
}

