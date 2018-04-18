#cloud-config
environment:
  environment: ${environment}
  dcos_username: ${dcos_username}
  dcos_password: ${dcos_password}
  dcos_nodes: ${dcos_nodes}
  dcos_master_url: ${dcos_master_url}
  aws_s3_bucket: ${dcos_apps_bucket}
  aws_s3_bucket_domain: ${dcos_apps_bucket_domain}
  online_prediction_sqs_queue: ${online_prediction_sqs_queue}
  app_aws_access_key_id: ${apps_aws_access_key}
  app_aws_secret_access_key: ${apps_aws_secret_key}
  aws_default_region: ${aws_region}
  dcos_master: ${dcos_master_url}
  baile_lb_url: ${baile_lb_url}
  baile_internal_lb_url: ${baile_internal_lb_url}
  redshift_host: ${redshift_host}
  redshift_user: ${redshift_user}
  redshift_password: ${redshift_password}
  zookeeper_url: "${dcos_master_url}:2181"
  marathon_client_marathon_endpoint: "http://${dcos_master_url}:8080"
  master_instance_name: ${master_instance_name}
  rabbit_password: ${rabbit_password}
  aries_http_search_user_password: ${aries_http_search_user_password}
  aries_http_command_user_password: ${aries_http_command_user_password}
  argo_http_auth_user_password: ${argo_http_auth_user_password}
  cortex_http_search_user_password: ${cortex_http_search_user_password}
  online_prediction_password: ${online_prediction_password}
  online_prediction_stream_id: ${online_prediction_stream_id}
  orion_http_search_user_password: ${orion_http_search_user_password}
  pegasus_http_auth_user_password: ${pegasus_http_auth_user_password}
  mongodb_app_password: ${mongodb_app_password}
  mongodb_rootadmin_password: ${mongodb_rootadmin_password}
  mongodb_useradmin_password: ${mongodb_useradmin_password}
  mongodb_clusteradmin_password: ${mongodb_clusteradmin_password}
  mongodb_clustermonitor_password: ${mongodb_clustermonitor_password}
  mongodb_backup_password: ${mongodb_backup_password}
  argo_docker_image_version: ${argo_docker_image_version}
  aries_docker_image_version: ${aries_docker_image_version}
  baile_docker_image_version: ${baile_docker_image_version}
  baile_haproxy_docker_image_version: ${baile_haproxy_docker_image_version}
  cortex_docker_image_version: ${cortex_docker_image_version}
  logstash_docker_image_version: ${logstash_docker_image_version}
  orion_docker_image_version: ${orion_docker_image_version}
  job_master_docker_image: ${job_master_docker_image}
  pegasus_docker_image_version: ${pegasus_docker_image_version}
  rmq_docker_image_version: ${rmq_docker_image_version}
  taurus_docker_image_version: ${taurus_docker_image_version}
  um_docker_image_version: ${um_docker_image_version}
  salsa_version: ${salsa_version}
  upload_datasets: "${upload_datasets}"
  download_from_s3: "${download_from_s3}"
  online_prediction: "${online_prediction}"
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
  - if [ ${download_ssh_keys} = true ]; then aws s3 cp s3://${ssh_keys_s3_bucket} - >> /home/${main_user}/.ssh/authorized_keys; fi
  - service mongod stop
