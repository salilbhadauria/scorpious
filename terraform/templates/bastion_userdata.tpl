#cloud-config
environment:
  environment: ${environment}
  aws_default_region: ${aws_region}
runcmd:
  - sudo yum-config-manager --disable rhui-REGION-client-config-server-7 || true
  - sudo yum-config-manager --disable rhui-REGION-rhel-server-releases || true
  - sudo yum-config-manager --disable rhui-REGION-rhel-server-rh-common || true
  - sudo yum-config-manager --disable nodesource || true

  - yum install -y amazon-ssm-agent

  - curl -O https://${s3_endpoint}/${artifacts_s3_bucket}/pre-packages/awscli-bundle.zip
  - unzip awscli-bundle.zip
  - ./awscli-bundle/install -i /usr/local/aws -b /bin/aws

  - if [ ${download_ssh_keys} = true ]; then aws s3 cp s3://${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
