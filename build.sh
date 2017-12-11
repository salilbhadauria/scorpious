#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config> <aws_profile> or (<aws_access_key_id> and <aws_secret_access_key>) <customer_key> <dcos_username> <dcos_password> [args...]"
  echo " e.g.: $0 integration default XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX deepcortex password "
  exit 1
}

export TF_VAR_dcos_password=$DCOS_PASSWORD
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

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
