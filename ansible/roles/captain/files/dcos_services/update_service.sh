#!/bin/bash

TEMPLATE=$1
ENV_VARS=$2
APP_NAME=$3

source ${ENV_VARS}

envsubst < ${TEMPLATE} > marathon.json

dcos marathon app update $APP_NAME < marathon.json
