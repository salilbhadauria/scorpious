#!/bin/bash
set -eux

sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/rpm/python2-pip-8.1.2-6.el7.noarch.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/rpm/nodejs-6.14.1-1nodesource.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/rpm/nodesource-release-el7-1.noarch.rpm
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/awscli-1.15.4.tar.gz

#######INSTALLING  HTTPD AND CREATE REPO PACKAGES FOR MAKING LOCAL YUM SERVER #################################################################

sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/createrepo-0.9.9-28.el7.noarch.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/deltarpm-3.6-3.el7.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/python-deltarpm-3.6-3.el7.x86_64.rpm

sudo aws s3 sync s3://${ARTIFACTS_S3_BUCKET}/packages/newrpm/ /opt/
sudo createrepo /opt/

for i in $(ll /etc/yum.repos.d/ | awk '{print $NF}' | grep .repo)
do
    sudo mv /etc/yum.repos.d/$i /etc/yum.repos.d/$i-backup
done

sudo bash -c 'cat << EOF > /etc/yum.repos.d/local.repo
[local]
name=local packages
baseurl=file:///opt/
enabled=1
gpgcheck=0
EOF'

sudo yum-config-manager --enable local
sudo yum clean all
sudo rm -rf /var/cache/yum


for i in $(aws s3 ls s3://${ARTIFACTS_S3_BUCKET}/packages/pip/ | awk '{print $NF}' | grep ".gz")
 do
  sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/$i
 done


for i in $(aws s3 ls s3://${ARTIFACTS_S3_BUCKET}/packages/npm/ | awk '{print $NF}' | grep ".gz")
 do
    sudo  npm install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/npm/$i
 done


#if [ $MACHINE_OS = "centos" ]; then
#  sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
#  sudo rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
#  sudo yum -q -y install epel-release
#elif [ $MACHINE_OS = "rhel" ]; then
#  sudo yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#fi
rpm -Uvh https://s3.amazonaws.com/falcon-scorpius-assets/packages/newrpm/epel-release-latest-7.noarch.rpm 
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
