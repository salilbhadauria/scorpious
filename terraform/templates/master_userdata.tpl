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
  - newhostn="master-$instanceid"
  - echo "Exisitng hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostnamectl set-hostname $newhostn
  - service rsyslog restart
  - service ntpd restart
  - curl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
  - yum install -y amazon-ssm-agent.rpm
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp ${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
  - sysctl net.bridge.bridge-nf-call-iptables=1
  - sysctl net.bridge.bridge-nf-call-ip6tables=1
  - until $(curl --output /dev/null --silent --head --fail http://${bootstrap_dns}:8080/dcos_install.sh); do sleep 30; done
  - curl http://${bootstrap_dns}:8080/dcos_install.sh -o /tmp/dcos_install.sh -s
  - cd /tmp; bash dcos_install.sh master
  - service ntpd restart
  - systemctl start amazon-ssm-agent
