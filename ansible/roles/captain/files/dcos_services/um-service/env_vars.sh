#!/bin/bash
export DOCKER_IMAGE_VERSION=${UM_DOCKER_IMAGE_VERSION}
export MONGODB_URI="mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@${MONGODB_BASE_URI}/um-service?replicaSet=rs&authSource=admin"
export EMAIL_ON=${EMAIL_ON}
export SRV_INSTANCES=${UM_SRV_INSTANCES}
export SRV_CPUS=${UM_SRV_CPUS}
export SRV_MEM=${UM_SRV_MEM}
