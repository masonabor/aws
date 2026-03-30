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

                # Чекаємо розблокування apt (критично для Ubuntu)
                echo "Waiting for apt lock..."
                while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done

                # Оновлення та встановлення базових залежностей
                apt-get update -y
                apt-get install -y ca-certificates curl gnupg

                # Налаштування ключів Docker
                install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                chmod a+r /etc/apt/keyrings/docker.asc

                # Додавання репозиторію (використовуємо $$ для екранування змінних Terraform)
                echo \
                    "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                    $$(. /etc/os-release && echo "$$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

                # Встановлення Docker та плагінів
                apt-get update -y
                apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

                # Запуск та налаштування прав
                systemctl start docker
                systemctl enable docker
                usermod -aG docker ubuntu

                # Створення посилання для docker-compose (щоб працювала команда з дефісом)
                ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
                
                echo "Docker installation finished successfully!"
                EOF
    
    tags = {
        Name = "DockerAppServer"
    }
}


output "instance_public_ip" {
    value = aws_instance.lab6_server.public_ip
}