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
  default = "AKIAYNTYVWHWB5FFTYU6"
}

variable "secret_key" {
  type    = string
  default = "jdRkT4u7D8xWRiHazKqVLeJ8uYzPRuVsCukkHh1e"
}

source "amazon-ebs" "example" {
  access_key    = var.access_key
  secret_key    = var.secret_key
  region        = "us-east-1"
  source_ami    = "ami-04b107e90218672e5"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer-mongodb-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list",
      "sudo apt-get update -y",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl start mongod",
      "sudo systemctl enable mongod"
    ]
  }
}