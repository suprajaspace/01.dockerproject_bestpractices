#!/bin/bash
sudo yum install -y yum-utils
sudo yum config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin -y docker-compose-plugin -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo docker ps

echo "docker install success"