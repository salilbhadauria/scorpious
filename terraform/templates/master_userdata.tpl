#cloud-config
environment:
  environment: ${environment}
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
  - sysctl net.bridge.bridge-nf-call-iptables=1
  - sysctl net.bridge.bridge-nf-call-ip6tables=1
  - until $(curl --output /dev/null --silent --head --fail http://${bootstrap_dns}:8080/dcos_install.sh); do sleep 5; done
  - curl http://${bootstrap_dns}:8080/dcos_install.sh -o /tmp/dcos_install.sh -s
  - cd /tmp; bash dcos_install.sh master
