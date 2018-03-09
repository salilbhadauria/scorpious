#!/bin/bash

export DCOS_MASTER_PRIVATE_IP=$(aws ec2 describe-instances --filter Name=tag-key,Values=Name Name=tag-value,Values=$MASTER_INSTANCE_NAME --query "Reservations[*].Instances[*].PrivateIpAddress" --output=text)
ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 27017:mongodb.mongodb-replicaset.l4lb.thisdcos.directory:27017 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10 & mongo "mongodb://localhost:27017/?replicaSet=rs"