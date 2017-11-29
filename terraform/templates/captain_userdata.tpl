#cloud-config
environment:
  environment: ${environment}
  dcos_master_url: ${dcos_master_url}
  aws_s3_bucket: ${dcos_apps_bucket}
  job_master_s3_region: ${aws_region}
  job_master_s3_bucket: ${dcos_apps_bucket}
  dcos_master: ${dcos_master_url}
  baile_lb_url: "baile_lb_url"
  redshift_host: ${redshift_host}
  redshift_user: ${redshift_user}
  redshift_password: ${redshift_password}
  mongodb_hosts: "mongo_hosts"
  um_service_url: "um_service_url"
  zookeeper_url: "${dcos_master_url}:2181"
  marathon_client_marathon_endpoint: "http://${dcos_master_url}:8080"
manage_resolv_conf: false
preserve_hostname: true
runcmd:
  - instanceid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-')
  - hostn=$(cat /etc/hostname)
  - newhostn="captain-$instanceid"
  - echo "Exisitng hostname is $hostn"
  - echo "New hostname will be $newhostn"
  - sed -i "s/localhost/$newhostn/g" /etc/hosts
  - sed -i "s/$hostn/$newhostn/g" /etc/hostname
  - hostnamectl set-hostname $newhostn
  - service rsyslog restart
  - service ntpd restart
  - until $(curl --output /dev/null --silent --head --fail http://${dcos_master_url}/); do sleep 5; done
  - cd /opt/dcos_services; bash deploy_all_services.sh
