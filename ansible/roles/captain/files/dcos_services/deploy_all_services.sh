#!/bin/bash

cd /opt/dcos_services/

# Stop mongo if running
service mongod stop

# Add S3 bucket encryption
aws s3api put-bucket-encryption --bucket "${AWS_S3_BUCKET}" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# Upload front end files to S3
aws s3 ls "s3://${AWS_S3_BUCKET}/static-content/dev/"
if [[ $? -ne 0 ]]; then
  curl -O https://s3.amazonaws.com/dev.deepcortex.ai/deployment_downloads/front-end.tar.gz
  tar -xvf front-end.tar.gz
  aws s3 sync front-end "s3://${AWS_S3_BUCKET}/static-content/dev/"
  rm -rf front-end

  if [ $UPLOAD_MSTAR_DATA = "true" ]; then
    curl -O https://s3.amazonaws.com/dev.deepcortex.ai/deployment_downloads/MSTAR_Data.tar.gz
    tar -xvf MSTAR_Data.tar.gz
    aws s3 sync MSTAR_Data "s3://${AWS_S3_BUCKET}/MSTAR_Data"
    rm -rf MSTAR_Data
  fi  
fi

# Wait for master node to become online
until $(curl --output /dev/null --silent --head --fail http://$DCOS_MASTER:/); do sleep 30; done

# Configure the DC/OS cli
bash setup_dcos_cli.sh

# Wait for all nodes to become online
until [[ $(dcos node | grep agent | wc -l) == $DCOS_NODES ]]; do sleep 30; done

sleep 60

# Retrieve slave node IPs
export MONGODB_HOSTS=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" --output text | sed -e 's/\s/,/g')
echo "$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" | jq -r '.[]')" > mongo_hosts.txt
export DCOS_MASTER_PRIVATE_IP=$(aws ec2 describe-instances --filter Name=tag-key,Values=Name Name=tag-value,Values=$MASTER_INSTANCE_NAME --query "Reservations[*].Instances[*].PrivateIpAddress" --output=text)

# Deploy frameworks from DC/OS universe + rabbitMQ
dcos package install marathon-lb --yes
dcos package install mongodb-replicaset --options=mongodb/options.json --yes
dcos package install elastic --options=elasticsearch/options.json --yes
dcos package install kibana --yes
bash deploy_service.sh rabbitmq/marathon.json rabbitmq/env_vars.sh
dcos package install --cli elastic --yes
dcos package install --cli mongodb-replicaset --yes

# Initialization and migration

while $(dcos marathon deployment list | grep -q scale); do sleep 30; done

export PATH="/usr/local/lib/npm/bin:$PATH"
sleep 60
bash elasticsearch/scripts/elasticsearch_init.sh
bash rabbitmq/rabbitmq_init.sh
bash mongodb/mongo_init.sh

# Deploy custom services and frameworkds
bash deploy_service.sh aries/marathon.json aries/env_vars.sh
bash deploy_service.sh baile/marathon.json baile/env_vars.sh
bash deploy_service.sh baile-nginx/marathon.json baile-nginx/env_vars.sh
bash deploy_service.sh cortex/marathon.json cortex/env_vars.sh
bash deploy_service.sh logstash/marathon.json logstash/env_vars.sh
bash deploy_service.sh orion/marathon.json orion/env_vars.sh
bash deploy_service.sh um-service/marathon.json um-service/env_vars.sh
