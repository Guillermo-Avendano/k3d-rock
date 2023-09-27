#!/bin/bash
sudo yum update -y

sudo yum install -y dos2unix

sudo yum install -y nano

sudo yum install git -y

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Enable and start docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service

#Add user to docker group
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock