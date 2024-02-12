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
    source      = "./mongo.js"
    destination = "/home/ubuntu/mongo.js"
  }

  provisioner "file" {
    source      = "./package.json"
    destination = "/home/ubuntu/package.json"
  }

  provisioner "file" {
    source      = "./setup_nginx.sh"
    destination = "/tmp/setup_nginx.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup_nginx.sh",
      "sudo /tmp/setup_nginx.sh",
      "cd /home/ubuntu",
      "sudo npm install",
      "sudo pm2 start /home/ubuntu/mongo.js --name 'mongo-app'",
      "sudo pm2 save",
      "sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu"
    ]
  }
}
