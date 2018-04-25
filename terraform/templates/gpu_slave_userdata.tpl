#cloud-config
environment:
  environment: ${environment}
  aws_default_region: ${aws_region}
manage_resolv_conf: false
preserve_hostname: true
runcmd:
  - instanceid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-')
  - hostn=$(cat /etc/hostname)
  - newhostn="gpu-slave-$instanceid"
  - echo "Exisitng hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostnamectl set-hostname $newhostn
  - service rsyslog restart
  - service ntpd restart
  - yum install -y amazon-ssm-agent.rpm
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp s3://${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
  - sysctl net.bridge.bridge-nf-call-iptables=1
  - sysctl net.bridge.bridge-nf-call-ip6tables=1
  - zone_id=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
  - mkdir -p /var/lib/dcos
  - touch /var/lib/dcos/mesos-slave-common || exit
  - echo "MESOS_ATTRIBUTES='az_id:$zone_id;cluster:gpu;'" > /var/lib/dcos/mesos-slave-common
  - until $(curl --output /dev/null --silent --head --fail http://${bootstrap_dns}:8080/dcos_install.sh); do sleep 5; done
  - curl http://${bootstrap_dns}:8080/dcos_install.sh -o /tmp/dcos_install.sh -s
  - cd /opt/gpu_support; bash install_gpu.sh
  - cd /tmp; bash dcos_install.sh slave
  - service ntpd restart
  - systemctl start amazon-ssm-agent
  - reboot
