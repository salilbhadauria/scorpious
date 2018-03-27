#cloud-config
environment:
  environment: ${environment}
  aws_default_region: ${aws_region}
  download_ssh_keys: ${download_ssh_keys}
  ssh_keys_s3_bucket: ${ssh_keys_s3_bucket}
  main_user: ${main_user}
manage_resolv_conf: false
preserve_hostname: true
runcmd:
  - instanceid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-')
  - hostn=$(cat /etc/hostname)
  - newhostn="bootstrap-$instanceid"
  - echo "Exisitng hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostnamectl set-hostname $newhostn
  - service rsyslog restart
  - service ntpd restart
  - curl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
  - yum install -y amazon-ssm-agent.rpm
  - sed -i "s/cluster_name_via_user_data/${cluster_name}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/s3_bucket_via_user_data/${s3_bucket}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/s3_prefix_via_user_data/${s3_prefix}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/provider_dns_via_user_data/${dns_ip}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/num_masters_via_user_data/${num_masters}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/masters_elb_dns_via_user_data/${masters_elb}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/bootstrap_dns_via_user_data/${bootstrap_dns}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/aws_region_via_user_data/${aws_region}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp ${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
  - cd /var/lib/dcos-bootstrap; bash dcos_generate_config.sh --set-superuser-password ${dcos_password}
  - cd /var/lib/dcos-bootstrap; bash dcos_generate_config.sh
  - docker pull httpd:2.4.23
  - docker run --name dcos_haproxy -p 8080:80 -v /var/lib/dcos-bootstrap/genconf/serve:/usr/local/apache2/htdocs/:ro httpd:2.4.23