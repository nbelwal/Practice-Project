provider "aws" {
  region = "ap-south-1"
}

data "aws_security_group" "testsg" {
  name = "allow_all_sg"
}

# Check if an instance with a specific tag already exists
data "aws_instances" "existing_instance" {
  filter {
    name   = "tag:Name"
    values = ["Minikube-EC2"]
  }
}

# Define the EC2 instance
resource "aws_instance" "ec2_instance" {
  count           = length(data.aws_instances.existing_instance.ids) == 0 ? 1 : 0
  ami             = "ami-00bb6a80f01f03502"  
  instance_type   = "t3.small"
  security_groups = [data.aws_security_group.testsg.name]
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

    # Install minikube 
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/

  EOF

  # Tags for the instance
  tags = {
    Name = "Minikube-EC2"
  }
}

# Output the public IP of the EC2 instance
output "ec2_instance_public_ip" {
  value = length(data.aws_instances.existing_instance.ids) > 0 ? data.aws_instances.existing_instance.public_ip : aws_instance.ec2_instance[0].public_ip
}
