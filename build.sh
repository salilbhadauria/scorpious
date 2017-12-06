#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> <aws_profile> <dcos_customer_key> <dcos_username> <dcos_password> <docker_registry_auth_token> [args...]"
  echo " e.g.: $0 integration default XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX deepcortex password XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  exit 1
}

if [ ${#} -ne 6 ]; then
  usage
fi

export CONFIG=$1
export AWS_PROFILE=$2
export CUSTOMER_KEY=$3
export DCOS_USERNAME=$4
export DCOS_PASSWORD=$5
export DOCKER_REGISTRY_AUTH_TOKEN=$6
export TF_VAR_dcos_password=$DCOS_PASSWORD
export APP_AWS_ACCESS_KEY_ID=$(grep -A3 -n "\[$AWS_PROFILE\]" ~/.aws/credentials | awk -F\= '/aws_access_key_id/{print $2}')
export APP_AWS_SECRET_ACCESS_KEY=$(grep -A3 -n "\[$AWS_PROFILE\]" ~/.aws/credentials | awk -F\= '/aws_secret_access_key/{print $2}')

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
