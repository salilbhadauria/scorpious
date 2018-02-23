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

aws s3 rm "s3://$AWS_DCOS_STACK_BUCKET" --recursive
aws s3 rm "s3://$AWS_DCOS_APPS_BUCKET" --recursive

STACKS=("${PREFIX}platform")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh plan-destroy $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done

echo "Platform destroyed."