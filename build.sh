#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> <aws_access_key_id> <aws_secret_access_key> <dcos_customer_key> <dcos_username> <dcos_password> [args...]"
  echo " e.g.: $0 integration default XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX deepcortex password "
  exit 1
}

if [ ${#} -ne 5 ]; then
  usage
fi

export CONFIG=$1
export AWS_ACCESS_KEY_ID=$2
export AWS_SECRET_ACCESS_KEY=$3
export CUSTOMER_KEY=$4
export DCOS_USERNAME=$5
export DCOS_PASSWORD=$6
export TF_VAR_dcos_password=$DCOS_PASSWORD

shift 6

sh terraform_init_backend.sh $CONFIG

IMAGES=("captain" "bootstrap" "master" "slave")
for i in "${IMAGES[@]}"; do
  sh packer.sh $i $CONFIG;
done

STACKS=("iam" "vpc" "redshift" "platform")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done
