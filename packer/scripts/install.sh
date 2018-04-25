#!/bin/bash
set -eux

sudo rpm --force --nodeps  -Uvh  https://s3.amazonaws.com/falcon-scorpius-assets/packages/rpm/wget-1.14-15.el7_4.1.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://s3.amazonaws.com/falcon-scorpius-assets/packages/rpm/python2-pip-8.1.2-6.el7.noarch.rpm
sudo rpm --force --nodeps  -Uvh  https://s3.amazonaws.com/falcon-scorpius-assets/packages/rpm/nodejs-6.14.1-1nodesource.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://s3.amazonaws.com/falcon-scorpius-assets/packages/rpm/nodesource-release-el7-1.noarch.rpm
sudo pip install https://s3.amazonaws.com/falcon-scorpius-assets/packages/pip/awscli-1.15.4.tar.gz


sudo aws configure set aws_access_key_id AKIAI6BMAUGJBUNKTLYQ
sudo aws configure set aws_secret_access_key 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 
sudo aws configure set default.region us-east-2

#######INSTALLING  HTTPD AND CREATE REPO PACKAGES FOR MAKING LOCAL YUM SERVER #################################################################

sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/createrepo-0.9.9-28.el7.noarch.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/deltarpm-3.6-3.el7.x86_64.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/python-deltarpm-3.6-3.el7.x86_64.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/apr-util-1.5.2-6.el7.x86_64.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/httpd-tools-2.4.6-80.el7.x86_64.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/mailcap-2.1.41-2.el7.noarch.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/redhat-logos-70.0.3-6.el7.noarch.rpm
sudo rpm -ivh https://s3.us-east-2.amazonaws.com/falcon-pre-packages/httpd-2.4.6-80.el7.x86_64.rpm
sudo aws s3 sync s3://falcon-scorpius-assets/packages/newrpm/ /var/www/html/
sudo createrepo /var/www/html

for i in `ll /etc/yum.repos.d/ | awk '{print $NF}' | grep .repo`
do
sudo mv $i $i-backup
done

cat >/etc/yum.repos.d/local.repo<< EOF
[local]
name=local packages
baseurl=http://localhost
enabled=1
gpgcheck=0
EOF

sudo yum-config-manager --enable local
sudo yum clean all
sudo rm -rf /var/cache/yum

sudo service httpd restart

for i in `aws s3 ls s3://falcon-scorpius-assets/packages/pip/ | awk '{print $NF}'`
do
pip install https://s3.amazonaws.com/falcon-scorpius-assets/packages/pip/$i
done


for i in `aws s3 ls s3://falcon-scorpius-assets/packages/npm/ | awk '{print $NF}'`

do
npm install https://s3.amazonaws.com/falcon-scorpius-assets/packages/npm/$i
done


#if [ $MACHINE_OS = "centos" ]; then
#  sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
#  sudo rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
#  sudo yum -q -y install epel-release
#elif [ $MACHINE_OS = "rhel" ]; then
#  sudo yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#fi

sudo yum -q -y install deltarpm
#sudo yum -q -y update

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
sudo yum remove createrepo -y 
sudo yum remove httpd -y 
