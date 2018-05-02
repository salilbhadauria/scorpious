#!/bin/bash
set -eux

curl -O https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/awscli-bundle.zip
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /bin/aws

sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/python2-pip-8.1.2-6.el7.noarch.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/nodejs-6.14.1-1nodesource.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/nodesource-release-el7-1.noarch.rpm

sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/setuptools-39.1.0.zip

sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/urllib3-1.22-py2.py3-none-any.whl
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/python_utils-2.3.0-py2.py3-none-any.whl
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/progressbar2-3.36.0-py2.py3-none-any.whl
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/backports.csv-1.0.5-py2.py3-none-any.whl
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/elasticsearch-5.5.2-py2.py3-none-any.whl
sudo pip install https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/pip/es2csv-5.5.2-py27-none-any.whl

#######INSTALLING  HTTPD AND CREATE REPO PACKAGES FOR MAKING LOCAL YUM SERVER #################################################################

sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/createrepo-0.9.9-28.el7.noarch.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/deltarpm-3.6-3.el7.x86_64.rpm
sudo rpm --force --nodeps  -Uvh  https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/pre-packages/python-deltarpm-3.6-3.el7.x86_64.rpm

sudo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION aws s3 sync s3://${ARTIFACTS_S3_BUCKET}/packages/rpm/ /opt/
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
sudo yum-config-manager --disable rhui-REGION-client-config-server-7
sudo yum-config-manager --disable rhui-REGION-rhel-server-releases
sudo yum-config-manager --disable rhui-REGION-rhel-server-rh-common
sudo yum-config-manager --disable nodesource
sudo yum clean all
sudo rm -rf /var/cache/yum

curl -O https://${S3_ENDPOINT}/${ARTIFACTS_S3_BUCKET}/packages/npm/node_modules.tar.gz
sudo tar -xvf node_modules.tar.gz -C /usr/lib/

sudo ln -s /usr/lib/node_modules/east/bin/east /usr/bin/east

#if [ $MACHINE_OS = "centos" ]; then
#  sudo rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
#  sudo rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
#  sudo yum -q -y install epel-release
#elif [ $MACHINE_OS = "rhel" ]; then
#  sudo yum -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#fi
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