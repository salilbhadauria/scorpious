#!/bin/bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

MONGO_HOST_0=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

export MONGO_PRIMARY=$(mongo --quiet "mongodb://$MONGO_HOST_0:27017/?replicaSet=rs" --eval "rs.isMaster().primary" | tail -1)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/migrate-mongo.sh baile
source $DIR/migrate-mongo.sh um
