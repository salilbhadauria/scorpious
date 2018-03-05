#!/bin/bash

# -s: stacks - a list of comma separated values to overwrite which asgs to shutdown

usage() {
  echo "Usage: Must set environment variables for CONFIG, AWS_PROFILE or (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY)"
  exit 1
}

VARS=("CONFIG")
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

export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")
ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")
OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")

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

ASGS=("slave" "gpu-slave" "public-slave" "captain" "bootstrap" "master" "bastion")

parse_args "$@"

for i in "${ASGS[@]}"; do
  aws autoscaling suspend-processes --auto-scaling-group-name "$OWNER-$ENVIRONMENT-$i-asg"
  echo "$OWNER-$ENVIRONMENT-$i-asg suspended"
  instance_ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$OWNER-$ENVIRONMENT-$i-asg" --query "AutoScalingGroups[].Instances[].InstanceId" --output text)
  for i in $instance_ids; do
    echo "stopping instance $i"
    aws ec2 stop-instances --instance-ids $i
  done
done