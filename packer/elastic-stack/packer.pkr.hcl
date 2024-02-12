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
  ami_name      = "packer-elastic-stack-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg",
      "curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee /etc/apt/sources.list.d/elastic-7.x.list",
      "sudo apt-get update -y",
      "sudo apt-get install -y elasticsearch",
      "sudo systemctl start elasticsearch",
      "sudo systemctl enable elasticsearch",
      "sudo apt-get install -y logstash",
      "sudo systemctl start logstash",
      "sudo systemctl enable logstash",
      "sudo apt-get install -y kibana",
      "sudo systemctl start kibana",
      "sudo systemctl enable kibana",
      "sudo ufw allow 5601",
      "sudo ufw allow 9200",
      "sudo ufw allow 5044"
    ]
  }
}
