#cloud-config
environment:
  environment: ${environment}
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
  - sed -i "s/cluster_name_via_user_data/${cluster_name}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/s3_bucket_via_user_data/${s3_bucket}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/s3_prefix_via_user_data/${s3_prefix}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/provider_dns_via_user_data/${dns_ip}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/num_masters_via_user_data/${num_masters}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/masters_elb_dns_via_user_data/${masters_elb}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/bootstrap_dns_via_user_data/${bootstrap_dns}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - sed -i "s/aws_region_via_user_data/${aws_region}/g" /var/lib/dcos-bootstrap/genconf/config.yaml
  - cd /var/lib/dcos-bootstrap; bash dcos_generate_config.sh --hash-password ${dcos_password}
  - docker pull nginx
  - docker run --name dcos_nginx -p 8080:80 -v /var/lib/dcos-bootstrap/genconf/serve:/usr/share/nginx/html:ro nginx
