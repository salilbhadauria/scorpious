#!/bin/bash
export DOCKER_IMAGE_VERSION=${BAILE_DOCKER_IMAGE_VERSION}
export AWS_S3_BUCKET=${AWS_S3_BUCKET}
export AWS_REGION=${AWS_DEFAULT_REGION}
export REDSHIFT_HOST=${REDSHIFT_HOST}
export REDSHIFT_USER=${REDSHIFT_USER}
export REDSHIFT_PASSWORD=${REDSHIFT_PASSWORD}
export MONGODB_HOSTS=${MONGODB_HOSTS}
export MONGODB_AUTH=${MONGODB_AUTH}
export MONGODB_USER=${MONGODB_USER}
export MONGODB_PASSWORD=${MONGODB_PASSWORD}
export AWS_ACCESS_KEY_ID=${APP_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${APP_AWS_SECRET_ACCESS_KEY}
export UM_SERVICE_URL=${UM_SERVICE_URL}
export CORTEX_HOST=${CORTEX_HOST}
export CORTEX_PORT=${CORTEX_PORT}
export CORTEX_REST_VERSION=${BAILE_CORTEX_REST_VERSION}
export CORTEX_SEARCH_USER=${CORTEX_HTTP_SEARCH_USER_NAME}
export CORTEX_SEARCH_PASSWORD=${CORTEX_HTTP_SEARCH_USER_PASSWORD}
export ARIES_HOST=${ARIES_HOST}
export ARIES_PORT=${ARIES_PORT}
export ARIES_REST_VERSION=${BAILE_ARIES_REST_VERSION}
export ARIES_SEARCH_USER=${ARIES_HTTP_SEARCH_USER_NAME}
export ARIES_SEARCH_PASSWORD=${ARIES_HTTP_SEARCH_USER_PASSWORD}
export ARGO_HOST=${ARGO_HOST}
export ARGO_PORT=${ARGO_PORT}
export ARGO_REST_VERSION=${BAILE_ARGO_REST_VERSION}
export ARGO_HTTP_USER=${ARGO_HTTP_AUTH_USER_NAME}
export ARGO_HTTP_PASSWORD=${ARGO_HTTP_AUTH_USER_PASSWORD}
export ONLINE_PREDICTION_USERNAME=${ONLINE_PREDICTION_USERNAME}
export ONLINE_PREDICTION_PASSWORD=${ONLINE_PREDICTION_PASSWORD}
export ONLINE_PREDICTION_STREAM_ID=${ONLINE_PREDICTION_STREAM_ID}
export SRV_INSTANCES=${BAILE_SRV_INSTANCES}
export SRV_CPUS=${BAILE_SRV_CPUS}
export SRV_MEM=${BAILE_SRV_MEM}
