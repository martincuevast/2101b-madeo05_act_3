packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "access_key" {
  type    = string
  default = "AKIAYNTYVWHWNTA4TDYO"
}

variable "secret_key" {
  type    = string
  default = "WbS0ZYtfNZqN88tvZ2HzXzPxdlib2GGMx4WIqGmz"
}

source "amazon-ebs" "example" {
  access_key    = var.access_key
  secret_key    = var.secret_key
  region        = "us-east-1"
  source_ami    = "ami-04b107e90218672e5"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer-mean-stack-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg",
      "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      // No es necesario instalar npm por separado, ya que viene con Node.js
      "sudo npm install -g pm2",
      "sudo apt-get install -y nginx",
      "sudo rm -f /etc/nginx/sites-enabled/default"
    ]
  }

  provisioner "file" {
    source      = "./templates/personas.ts"
    destination = "/home/ubuntu/personas.ts"
  }


  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g npm@latest",
      "sudo npm install -g pm2",
      "npm install @apollo/server graphql",
      "sudo npm start"
    ]
  }
}