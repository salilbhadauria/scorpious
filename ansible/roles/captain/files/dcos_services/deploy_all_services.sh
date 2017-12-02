#!/bin/bash

cd /opt/dcos_services/

# Wait for master node to become online
until $(curl --output /dev/null --silent --head --fail http://$DCOS_MASTER:/); do sleep 5; done

# Configure the DC/OS cli
source setup_dcos_cli.sh

# Wait for all nodes to become online
until [[ $(dcos node | grep agent | wc -l) == $DCOS_NODES ]]; do sleep 5; done

# Retrieve slave node IPs
export MONGODB_HOSTS=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" --query Reservations[].Instances[].PrivateIpAddress --output text | sed -e 's/\s/,/g')

# Deploy frameworks from DC/OS universe
dcos package install marathon-lb --yes
dcos package install mongodb-replicaset --yes
dcos package install elastic --options=elasticsearch/options.json --yes
dcos package install kibana --yes

# Deploy custom services and frameworkds
source deploy_service.sh aries/marathon.json aries/env_vars.sh
source deploy_service.sh baile/marathon.json baile/env_vars.sh
source deploy_service.sh baile-nginx/marathon.json baile-nginx/env_vars.sh
source deploy_service.sh cortex/marathon.json cortex/env_vars.sh
source deploy_service.sh logstash/marathon.json logstash/env_vars.sh
source deploy_service.sh orion/marathon.json orion/env_vars.sh
source deploy_service.sh rabbitmq/marathon.json rabbitmq/env_vars.sh
source deploy_service.sh um-service/marathon.json um-service/env_vars.sh
