#!/bin/bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

export DCOS_MASTER_PRIVATE_IP=$(aws ec2 describe-instances --filter Name=tag-key,Values=Name Name=tag-value,Values=$MASTER_INSTANCE_NAME --query "Reservations[*].Instances[*].PrivateIpAddress" --output=text)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 27017:mongodb.mongodb-replicaset.l4lb.thisdcos.directory:27017 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10
source "$DIR/migrate-baile-mongo.sh"
source "$DIR/migrate-um-mongo.sh"
