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
              set -e 

              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done
              
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
              
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