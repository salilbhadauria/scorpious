#!/bin/bash
set -eux

if [ $MACHINE_OS = "centos" ]; then
  sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
  sudo rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
  sudo yum -q -y install epel-release
elif [ $MACHINE_OS = "rhel" ]; then
  sudo yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi

sudo yum -q -y install deltarpm
sudo yum -q -y update

# Needed only for LVM amis
#sudo yum -q -y install cloud-utils-growpart
#sudo growpart /dev/xvda 2
#sudo pvresize /dev/xvda2
#sudo lvextend -l +100%FREE /dev/mapper/cl-root
#sudo xfs_growfs /dev/mapper/cl-root

sudo yum -q -y install ansible
cat <<EOF | sudo tee /etc/ansible/hosts
[${PACKER_BUILD_NAME}]
127.0.0.1 ansible_connection=local

EOF
