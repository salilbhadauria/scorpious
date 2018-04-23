#!/bin/bash

cd /opt/dcos_services/

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
fi

# Upload Datasets to S3
aws s3 ls "s3://${AWS_S3_BUCKET}/Datasets/"
if [[ $? -ne 0 ]]; then
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

# set local universe repo
if [[ "$USE_LOCAL_DCOS_UNIVERSE" = "true" ]]; then
  dcos package repo remove Universe || true
  dcos package repo add Universe http://$DCOS_MASTER:8082/repo
fi

# Retrieve slave node IPs
echo "$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" | jq -r '.[]')" > mongo_hosts.txt
export DCOS_MASTER_PRIVATE_IP=$(aws ec2 describe-instances --filter Name=tag-key,Values=Name Name=tag-value,Values=$MASTER_INSTANCE_NAME --query "Reservations[*].Instances[*].PrivateIpAddress" --output=text)

# Deploy frameworks from DC/OS universe + rabbitMQ
dcos package install marathon-lb --yes
bash deploy_catalog_service.sh percona-mongo mongodb/options.json mongodb/env_vars.sh
dcos package install elastic --options=elasticsearch/options.json --yes
dcos package install kibana --yes
bash deploy_service.sh rabbitmq/marathon.json rabbitmq/env_vars.sh
dcos package install --cli elastic --yes
dcos package install --cli percona-mongo --yes

# Initialization and migration

while $(dcos marathon deployment list | grep -q scale); do sleep 30; done

sleep 60

bash elasticsearch/scripts/elasticsearch_init.sh
bash rabbitmq/rabbitmq_init.sh

until [[ $(dcos percona-mongo pod status | grep TASK_RUNNING | wc -l) == 4 ]]; do sleep 30; done

sleep 30

dcos percona-mongo user reload-system useradmin $MONGODB_USERADMIN_PASSWORD

envsubst < mongodb/admin_user.json > admin_user.json
dcos percona-mongo user add admin admin_user.json useradmin $MONGODB_USERADMIN_PASSWORD

sleep 10

envsubst < mongodb/app_user.json > app_user.json
dcos percona-mongo user add admin app_user.json useradmin $MONGODB_USERADMIN_PASSWORD

export PATH="/usr/local/lib/npm/bin:$PATH"

bash mongodb/mongo_init.sh

# Deploy custom services and frameworks
bash deploy_service.sh aries-api-rest/marathon.json aries-api-rest/env_vars.sh
bash deploy_service.sh baile/marathon.json baile/env_vars.sh
bash deploy_service.sh baile-haproxy/marathon.json baile-haproxy/env_vars.sh
bash deploy_service.sh cortex-api-rest/marathon.json cortex-api-rest/env_vars.sh
bash deploy_service.sh logstash/marathon.json logstash/env_vars.sh
bash deploy_service.sh orion-api-rest/marathon.json orion-api-rest/env_vars.sh
bash deploy_service.sh um-service/marathon.json um-service/env_vars.sh

# Deploy online prediction
if [ $ONLINE_PREDICTION = "true" ]; then
  # Stop postgresql servers if running
  service postgresql stop

  # Initialize redshift
  bash postgres/postgres_init.sh

  # Deploy custom services
  bash deploy_service.sh argo-api-rest/marathon.json argo-api-rest/env_vars.sh
  bash deploy_service.sh pegasus-api-rest/marathon.json pegasus-api-rest/env_vars.sh
  bash deploy_service.sh taurus/marathon.json taurus/env_vars.sh
fi
