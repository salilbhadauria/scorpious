#!/bin/bash
set -eux

sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
sudo rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
sudo yum -q -y install epel-release
sudo yum -q -y install deltarpm
sudo yum -q -y update
sudo yum -q -y install cloud-utils-growpart
sudo growpart /dev/xvda 2
sudo pvresize /dev/xvda2
sudo lvextend -l +100%FREE /dev/mapper/cl-root
sudo xfs_growfs /dev/mapper/cl-root
sudo yum -q -y install ansible
echo "localhost ansible_connection=local" | sudo tee /etc/ansible/hosts
