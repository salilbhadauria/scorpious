#!/bin/bash
export DOCKER_IMAGE_VERSION=${BAILE_NGINX_DOCKER_IMAGE_VERSION}
export S3_BUCKET=${AWS_S3_BUCKET_DOMAIN}
export BAILE_LB_URL=${BAILE_LB_URL}
export SRV_INSTANCES=${BAILE_NGINX_SRV_INSTANCES}
export SRV_CPUS=${BAILE_NGINX_SRV_CPUS}
export SRV_MEM=${BAILE_NGINX_SRV_MEM}
