#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> [args...]"
  echo " e.g.: $0 integration "
  exit 1
}

export TF_VAR_dcos_password="${DCOS_PASSWORD}"
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")
AWS_DCOS_STACK_BUCKET=$(awk -F\" '/^dcos_stack_bucket/{print $2}'  "environments/$CONFIG.tfvars")
AWS_DCOS_APPS_BUCKET=$(awk -F\" '/^dcos_apps_bucket/{print $2}'  "environments/$CONFIG.tfvars")

if aws s3 ls "s3://$AWS_DCOS_STACK_BUCKET" 2>&1 | grep -q 'NoSuchBucket'
  then
    echo "No bucket to delete"
else
  echo "Deleting bucket $AWS_DCOS_STACK_BUCKET"
  aws s3 rm "s3://$AWS_DCOS_STACK_BUCKET" --recursive
fi

if aws s3 ls "s3://$AWS_DCOS_APPS_BUCKET" 2>&1 | grep -q 'NoSuchBucket'
  then
    echo "No bucket to delete"
else
  echo "Deleting bucket $AWS_DCOS_STACK_BUCKET"
  aws s3 rm "s3://$AWS_DCOS_APPS_BUCKET" --recursive
fi

STACKS=("${PREFIX}platform")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh plan-destroy $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done

echo "Platform destroyed."