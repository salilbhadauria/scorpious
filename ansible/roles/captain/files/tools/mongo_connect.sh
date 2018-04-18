#!/bin/bash

MONGODB_HOST_0=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
MONGODB_PRIMARY=$(mongo --quiet "mongodb://$MONGODB_HOST_0:27017/?replicaSet=rs" --eval "rs.isMaster().primary" | tail -1)

mongo "mongodb://useradmin:$MONGODB_USERADMIN_PASSWORD@$MONGODB_PRIMARY/admin?replicaSet=rs"