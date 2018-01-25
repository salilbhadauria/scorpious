#cloud-config
environment:
  environment: ${environment}
  dcos_nodes: ${dcos_nodes}
  dcos_master_url: ${dcos_master_url}
  aws_s3_bucket: ${dcos_apps_bucket}
  aws_s3_bucket_domain: ${dcos_apps_bucket_domain}
  app_aws_access_key_id: ${apps_aws_access_key}
  app_aws_secret_access_key: ${apps_aws_secret_key}
  aws_default_region: ${aws_region}
  job_master_s3_region: ${aws_region}
  job_master_s3_bucket: ${dcos_apps_bucket}
  job_master_s3_access_key: ${apps_aws_access_key}
  job_master_s3_secret_key: ${apps_aws_secret_key}
  dcos_master: ${dcos_master_url}
  baile_lb_url: ${baile_lb_url}
  redshift_host: ${redshift_host}
  redshift_user: ${redshift_user}
  redshift_password: ${redshift_password}
  zookeeper_url: "${dcos_master_url}:2181"
  marathon_client_marathon_endpoint: "http://${dcos_master_url}:8080"
  master_instance_name: ${master_instance_name}
  rabbit_password: ${rabbit_password}
  aries_http_search_user_password: ${aries_http_search_user_password}
  aries_http_command_user_password: ${aries_http_command_user_password}
  cortex_http_search_user_password: ${cortex_http_search_user_password}
  orion_http_search_user_password: ${orion_http_search_user_password}
  aries_docker_image_version: ${aries_docker_image_version}
  baile_docker_image_version: ${baile_docker_image_version}
  baile_nginx_docker_image_version: ${baile_nginx_docker_image_version}
  cortex_docker_image_version: ${cortex_docker_image_version}
  logstash_docker_image_version: ${logstash_docker_image_version}
  orion_docker_image_version: ${orion_docker_image_version}
  job_master_docker_image: ${job_master_docker_image}
  rmq_docker_image_version: ${rmq_docker_image_version}
  um_docker_image_version: ${um_docker_image_version}
  upload_mstar_data: "${upload_mstar_data}"
  download_from_s3: "${download_from_s3}"
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
  - curl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
  - yum install -y amazon-ssm-agent.rpm
  - service mongod stop
