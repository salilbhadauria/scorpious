#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> [args...]"
  echo " e.g.: $0 integration "
  exit 1
}

if [ ${#} -ne 1 ]; then
  usage
fi

export CONFIG=$1

shift 1

STACKS=("platform" "redshift" "vpc" "iam")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh plan-destroy $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done
