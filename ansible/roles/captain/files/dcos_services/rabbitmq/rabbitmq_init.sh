#!/bin/bash

export RABBITMQ_USER="$RABBIT_USERNAME"
export RABBITMQ_PASSWORD="$RABBIT_PASSWORD"

ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 5672:rabbitmq.marathon.l4lb.thisdcos.directory:5672 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10
java -jar rabbitmq_init.jar

sudo ssh -o StrictHostKeyChecking=no -f -L 15672:rabbitmq.marathon.l4lb.thisdcos.directory:15672 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10
curl -XPUT -i -u "$RABBITMQ_USER:$RABBITMQ_PASSWORD" -H "Content-Type: application/json" http://127.0.0.1:15672/api/policies/%2f/ha-all -d '{"pattern":".*", "definition":{"ha-mode":"all","ha-sync-mode":"automatic"}}'