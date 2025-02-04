provider "aws" {
  region = "ap-south-1"  
}

# Define the EC2 instance
resource "aws_instance" "ec2_instance" {
  ami             = "ami-00bb6a80f01f03502"  
  instance_type   = "t3.small"
  security_groups = ["sg-0a1ade90b668eee03"]
  key_name        = "keypair_aws" 

  # Install Docker, kubectl, and Minikube using user_data
  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    sudo apt update -y
    
    # Install Docker
   # Add Docker's official GPG key:
   # sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo groupadd docker 
    sudo usermod -aG docker ubuntu  
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER 
    
    # Install kubectl
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    
    # Install Minikube
   # curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
   # sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

    # Start Minikube
   # sudo minikube start
  EOF

  # Output the public IP of the EC2 instance
  tags = {
    Name = "Minikube-EC2"
  }
}

# Output the public IP of the instance
output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
