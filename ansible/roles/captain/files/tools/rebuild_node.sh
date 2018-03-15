#!/bin/bash

echo "Rebuilding elastic nodes"
bash elastic_rebuild.sh

echo "Rebuilding mongodb nodes"
bash mongodb_rebuild.sh

echo "Updating baile with new monogodb hosts"
export MONGODB_HOSTS=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" --output text | sed -e 's/\s/,/g')
bash ../dcos_services/update_service.sh ../dcos_services/baile/marathon.json ../dcos_services/baile/env_vars.sh baile