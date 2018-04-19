#!/bin/bash

SERVICE_NAME=$1
TEMPLATE=$2
ENV_VARS=$3

source ${ENV_VARS}

envsubst < ${TEMPLATE} > options.json

dcos package install $SERVICE_NAME --options=options.json --yes