terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket = "lab6bucket2288"
        key    = "aws/terraform.tfstate"
        region = "us-east-1"
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "lab6_sg" {
    name = "allow_web_ssh"
    description = "Allow ssh and http traffic"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "lab6_server" {
    ami = "ami-0b0ea68c435eb488d"
    instance_type = "t3.micro"
    key_name = "lab6key"
    vpc_security_group_ids = [aws_security_group.lab6_sg.id]

    user_data = <<-EOF
              #!/bin/bash
              set -e 

              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done
              
              sudo apt update
              sudo apt install ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc

              sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
                    Types: deb
                    URIs: https://download.docker.com/linux/ubuntu
                    Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
                    Components: stable
                    Architectures: $(dpkg --print-architecture)
                    Signed-By: /etc/apt/keyrings/docker.asc
              EOF

              sudo apt update
              sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              sudo apt-get install docker-compose-plugin

              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              
              ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
              EOF
    
    tags = {
        Name = "DockerAppServer"
    }
}


output "instance_public_ip" {
    value = aws_instance.lab6_server.public_ip
}