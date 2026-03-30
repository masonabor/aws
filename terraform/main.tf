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

user_data = <<EOF
#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  sleep 5
done

apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

docker --version
docker compose version
EOF
    

    tags = {
        Name = "Lab6"
    }
}

output "instance_public_ip" {
    value = aws_instance.lab6_server.public_ip
}