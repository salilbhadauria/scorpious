#!usr/bin/env bash

#script executed on captain node
#usage: sh create-docker-registry.sh

REGISTRY_MARATHON_FILE="registry-marathon.json"

dcos marathon app add $REGISTRY_MARATHON_FILE
