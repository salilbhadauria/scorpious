#!/bin/bash

CONFIG=$1

if [ ${#} -ne 1 ]; then
  echo "Must supply an arguement for CONFIG"
fi

AWS_DCOS_STACK_BUCKET=$(awk -F\" '/^dcos_stack_bucket/{print $2}'  "environments/$CONFIG.tfvars")
AWS_DCOS_APPS_BUCKET=$(awk -F\" '/^dcos_apps_bucket/{print $2}'  "environments/$CONFIG.tfvars")

# init vpc
./terraform.sh init $CONFIG s3_buckets

# import existing stack bucket
./terraform.sh import $CONFIG s3_buckets aws_s3_bucket.dcos_stack_bucket $AWS_DCOS_STACK_BUCKET

# import existing stack bucket
./terraform.sh import $CONFIG s3_buckets aws_s3_bucket.dcos_apps_bucket $AWS_DCOS_APPS_BUCKET

# refresh to obtain outputs
./terraform.sh refresh $CONFIG s3_buckets