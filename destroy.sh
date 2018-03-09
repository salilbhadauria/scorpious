#!/usr/bin/env bash
set -e

# optional arguments:
# -s: stacks - a list of comma separated values to overwrite which terraform stacks to destroy

usage() {
  echo "Usage: Must set environment variables for CONFIG, AWS_PROFILE or (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY), CUSTOMER_KEY, DCOS_USERNAME, DCOS_PASSWORD"
  exit 1
}

VARS=("CONFIG" "CUSTOMER_KEY" "DCOS_USERNAME" "DCOS_PASSWORD")
for i in "${VARS[@]}"; do
  if [[ -z "${!i}" ]];then
    echo "$i is not set"
    usage
  fi
done

if [[ -z "$AWS_PROFILE" ]] && ([[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]]);then
  echo "AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are not set"
  usage
fi

parse_args()
{
  while getopts ":s:" opt "$@"; do
    case "$opt" in
      s) set -f
         IFS=,
         STACKS=($OPTARG) ;;
      :) error "option -$OPTARG requires an argument." ;;
      \?) error "unknown option: -$OPTARG" ;;
    esac
  done
}

CLUSTER_NAME=$(awk -F\" '/^cluster_name/{print $2}'  "environments/$CONFIG.tfvars")
if dcos cluster list | grep -q "$CLUSTER_NAME"; then
  dcos cluster remove "$CLUSTER_NAME"
fi

export TF_VAR_dcos_password="${DCOS_PASSWORD}"
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

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

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")
STACKS=("iam" "vpc" "redshift" "platform" "online_prediction")

parse_args "$@"

for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG "$PREFIX$i";
  sh terraform.sh plan $CONFIG "$PREFIX$i";
  sh terraform.sh plan-destroy $CONFIG "$PREFIX$i";
  sh terraform.sh apply $CONFIG "$PREFIX$i";
done

echo "Artifacts destroyed."