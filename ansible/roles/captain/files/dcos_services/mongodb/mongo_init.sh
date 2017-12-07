#!/bin/bash
# Pre-requisites:
# npm install mongodb -g
# npm install east east-mongo -g

DIR=$(dirname ${BASH_SOURCE[0]})

ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 27917:mongodb.mongodb-replicaset.l4lb.thisdcos.directory:27017 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10
source "$DIR/migrate-baile-mongo.sh"
source "$DIR/migrate-um-mongo.sh"
