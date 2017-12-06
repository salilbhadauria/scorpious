#!/bin/bash

sudo ssh -o StrictHostKeyChecking=no -f -L 9200:coordinator.elastic.l4lb.thisdcos.directory:9200 centos@"$DCOS_MASTER_PRIVATE_IP" sleep 10
source build-index-jobs-dev.sh
source build-index-job-heartbeats-dev.sh
