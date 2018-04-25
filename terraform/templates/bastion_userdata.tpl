#cloud-config
environment:
  environment: ${environment}
  aws_default_region: ${aws_region}
runcmd:
  - yum install -y amazon-ssm-agent.rpm
  - easy_install pip
  - pip install awscli
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp s3://${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
