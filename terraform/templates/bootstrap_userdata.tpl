#cloud-config
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
  - bash /var/lib/dcos-bootstrap/dcos_generate_config.sh
  - docker pull nginx
  - docker run --name dcos_nginx -p 8080:80 -v /var/lib/dcos-bootstrap/genconf/serve:/usr/share/nginx/html:ro nginx
