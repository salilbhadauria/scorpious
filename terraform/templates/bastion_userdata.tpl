#cloud-config
environment:
  aws_default_region: ${aws_region}
  download_ssh_keys: ${download_ssh_keys}
  ssh_keys_s3_bucket: ${ssh_keys_s3_bucket}
  main_user: ${main_user}
runcmd:
  - curl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
  - yum install -y amazon-ssm-agent.rpm
  - easy_install pip
  - pip install awscli
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp ${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi