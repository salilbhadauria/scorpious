#!/bin/bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

ssh -o StrictHostKeyChecking=no -f -L 27017:mongodb.mongodb-replicaset.l4lb.thisdcos.directory:27017 centos@"$DCOS_MASTER_PRIVATE_IP" sleep 10
source migrate-baile-mongo.sh
source migrate-um-mongo.sh
