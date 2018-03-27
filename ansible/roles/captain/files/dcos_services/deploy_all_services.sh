#!/bin/bash

cd /opt/dcos_services/

# Stop mongo servers if running
service mongod stop

# Add S3 bucket encryption
aws s3api put-bucket-encryption --bucket "${AWS_S3_BUCKET}" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# Upload front end files to S3
aws s3 ls "s3://${AWS_S3_BUCKET}/static-content/dev/"
if [[ $? -ne 0 ]]; then
  if [ $DOWNLOAD_FROM_S3 = "true" ]; then
    curl -O "https://s3.amazonaws.com/artifacts.dev.deepcortex.ai/deployment_downloads/${SALSA_VERSION}/front-end.tar.gz"
  fi
  tar -xvf front-end.tar.gz
  aws s3 sync front-end "s3://${AWS_S3_BUCKET}/static-content/dev/"
  rm -rf front-end
  rm -f front-end.tar.gz

  if [ $UPLOAD_DATASETS = "true" ]; then
    if [ $DOWNLOAD_FROM_S3 = "true" ]; then
      curl -O "https://s3.amazonaws.com/artifacts.dev.deepcortex.ai/deployment_downloads/Datasets.tar.gz"
    fi
    tar -xvf Datasets.tar.gz
    aws s3 sync Datasets "s3://${AWS_S3_BUCKET}/Datasets"
    rm -rf Datasets
    rm -f Datasets.tar.gz
  fi
fi

# Wait for master node to become online
until $(curl --output /dev/null --silent --head --fail http://$DCOS_MASTER:/); do sleep 60; done

# Configure the DC/OS cli
bash setup_dcos_cli.sh

# Wait for all nodes to become online
until [[ $(dcos node | grep agent | wc -l) == $DCOS_NODES ]]; do sleep 30; done

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

sleep 60

export PATH="/usr/local/lib/npm/bin:$PATH"

bash elasticsearch/scripts/elasticsearch_init.sh
bash rabbitmq/rabbitmq_init.sh
bash mongodb/mongo_init.sh

# Deploy custom services and frameworks
bash deploy_service.sh aries/marathon.json aries/env_vars.sh
bash deploy_service.sh baile/marathon.json baile/env_vars.sh
bash deploy_service.sh baile-haproxy/marathon.json baile-haproxy/env_vars.sh
bash deploy_service.sh cortex/marathon.json cortex/env_vars.sh
bash deploy_service.sh logstash/marathon.json logstash/env_vars.sh
bash deploy_service.sh orion/marathon.json orion/env_vars.sh
bash deploy_service.sh um-service/marathon.json um-service/env_vars.sh

# Deploy online prediction
if [ $ONLINE_PREDICTION = "true" ]; then
  # Stop postgresql servers if running
  service postgresql stop

  # Initialize redshift
  bash postgres/postgres_init.sh

  # Deploy custom services
  bash deploy_service.sh argo/marathon.json argo/env_vars.sh
  bash deploy_service.sh pegasus/marathon.json pegasus/env_vars.sh
  bash deploy_service.sh taurus/marathon.json taurus/env_vars.sh
fi
