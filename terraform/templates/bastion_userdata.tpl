#cloud-config
environment:
  environment: ${environment}
  aws_default_region: ${aws_region}
runcmd:
  - yum install -y amazon-ssm-agent.rpm

  -  sudo rpm --force --nodeps -Uvh https://${s3_endpoint}/${artifacts_s3_bucket}/packages/rpm/python2-pip-8.1.2-6.el7.noarch.rpm
  -  sudo pip install https://${s3_endpoint}/${artifacts_s3_bucket}/packages/pip/awscli-1.15.4.tar.gz

  - if [ ${download_ssh_keys} = true ]; then aws s3 cp s3://${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
