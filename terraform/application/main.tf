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

# Crear una Internet Gateway para la VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainInternetGateway"
  }
}

# Crear una subnet en la VPC
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1"
  }
}

# Crear otra subnet en una zona de disponibilidad diferente
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet2"
  }
}

# Crear una ruta predeterminada a través de la Internet Gateway
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "MainRouteTable"
  }
}

# Asociar las subnets con la tabla de rutas
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group para las instancias EC2
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

  # HTTP para Nginx
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB port (27017) for incoming connections
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

# MongoDB Instance
resource "aws_instance" "application_instance1" {
  ami           = "ami-0c3e273ccdba74b7e"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id     = aws_subnet.subnet1.id

  user_data = <<-EOF
              #!/bin/bash
              sudo pm2 start /home/ubuntu/mongo.js --name 'mongo-app'
              sudo pm2 save
              sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
              EOF

  tags = {
    Name = "Application-Instance_1"
  }
  timeouts {
      create = "20m"  // Aumentar a 20 minutos, por ejemplo
    }
}