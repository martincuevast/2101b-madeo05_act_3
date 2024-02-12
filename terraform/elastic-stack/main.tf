provider "aws" {
  region = "us-east-1"
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
resource "aws_instance" "elastic-stack" {
  ami           = "ami-0a11ab9d3b2792504"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id     = "subnet-09030beb6744a0a9e"
  
  user_data = <<-EOF

              EOF

  tags = {
    Name = "Mongo-Instance"
  }
}

