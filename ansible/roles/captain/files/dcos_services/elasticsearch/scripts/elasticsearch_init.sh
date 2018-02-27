#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 9200:coordinator.elastic.l4lb.thisdcos.directory:9200 deployer@"$DCOS_MASTER_PRIVATE_IP" sleep 10
source "$DIR/build-index-jobs-dev.sh"
source "$DIR/build-index-job-heartbeats-dev.sh"
source "$DIR/build-index-config-settings-dev.sh"
