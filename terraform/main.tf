terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
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
                    sudo apt-get update
                    sudo apt-get install -y docker.io docker-compose
                    sudo systemctl start docker
                    sudo usermod -aG docker ubuntu
                    EOF
    
    tags = {
        Name = "DockerAppServer"
    }
}

output "instance_public_ip" {
    value = aws_instance.lab6_server.public_ip
}