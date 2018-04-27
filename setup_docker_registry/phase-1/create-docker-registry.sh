#!usr/bin/env bash

#script executed on captain node
#usage: bash create-docker-registry.sh martahon_file en_var_file

TEMPLATE=$1
ENV_VARS=$2

source ${ENV_VARS}

envsubst < ${TEMPLATE} > marathon.json

dcos marathon app add marathon.json
