#!/bin/bash

# -s: services - a list of comma separated values to overwrite which services to update
# -f: force - set to true to force updates

parse_args()
{
  while getopts ":f:s:" opt "$@"; do
    case "$opt" in
      f) FORCE="$OPTARG" ;;
      s) set -f
         IFS=,
         SERVICES=($OPTARG) ;;
      :) error "option -$OPTARG requires an argument." ;;
      \?) error "unknown option: -$OPTARG" ;;
    esac
  done
}

export MONGODB_HOSTS=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" --output text | sed -e 's/\s/,/g')

SERVICES=("argo-api-rest" "aries-api-rest" "baile" "cortex-api-rest" "orion-api-rest" "pegasus-api-rest" "taurus")

parse_args "$@"

for i in "${SERVICES[@]}"; do
  if [ $FORCE=true ]; then
    bash force_update_service.sh "$i";
  else
    bash update_service.sh "$i";
  fi
done