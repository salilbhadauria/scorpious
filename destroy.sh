#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> [args...]"
  echo " e.g.: $0 integration "
  exit 1
}

export TF_VAR_dcos_password="${DCOS_PASSWORD}"

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")

STACKS=("${PREFIX}monitoring" "${PREFIX}online_prediction" "${PREFIX}platform" "${PREFIX}redshift" "${PREFIX}vpc" "iam")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh plan-destroy $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done
