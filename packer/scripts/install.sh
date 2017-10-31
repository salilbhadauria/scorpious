#!/bin/bash
set -eux

sudo yum update -y
sudo yum install python-pip python-dev libffi-dev libssl-dev -y
sudo pip install --upgrade pip
sudo pip install pyOpenSSL==16.2.0
sudo pip install ansible==2.3.1.0
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts
