provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all_sg"
  description = "Security group allowing all traffic"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows all IPv4 traffic
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows all IPv4 traffic
  }

  tags = {
    Name = "AllowAllSecurityGroup"
  }
}

# Define the EC2 instance
resource "aws_instance" "ec2_instance" {
  ami             = "ami-00bb6a80f01f03502"  
  instance_type   = "t3.small"
  security_groups = [aws_security_group.allow_all.name]
  key_name        = "keypair_aws"

  # Install Docker, kubectl, and Minikube using user_data
  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    sudo apt update -y
    
    # Install Docker
    sudo apt-get install ca-certificates curl -y
    sudo groupadd docker
    sudo usermod -aG docker ubuntu
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  EOF

  # Tags for the instance
  tags = {
    Name = "Minikube-EC2"
  }

  # Prevent unnecessary recreation due to changes in user_data
  lifecycle {
    ignore_changes = [
      user_data,  # Ignore changes to user_data so it doesn't trigger an instance replacement
    ]
  }
}

# Output the public IP of the EC2 instance
output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
