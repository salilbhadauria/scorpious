#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config> <aws_profile> or (<aws_access_key_id> and <aws_secret_access_key>) <customer_key> <dcos_username> <dcos_password> [args...]"
  echo " e.g.: $0 integration default XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX deepcortex password "
  exit 1
}

export TF_VAR_dcos_password=$DCOS_PASSWORD
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

#sh terraform_init_backend.sh $CONFIG

#sh packer.sh all $CONFIG;

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")

STACKS=("iam" "${PREFIX}vpc" "${PREFIX}redshift" "${PREFIX}platform" "${PREFIX}monitoring")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done