#!/usr/bin/env bash
set -e

# optional arguments:
# -s: stacks - a list of comma separated values to overwrite which terraform stacks to destroy
# -d: can be set to true to delete s3 buckets

usage() {
  echo "Usage: Must set environment variables for CONFIG, AWS_PROFILE or (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY), CUSTOMER_KEY, DCOS_USERNAME, DCOS_PASSWORD, DOCKER_EMAIL_LOGIN, DOCKER_REGISTRY_AUTH_TOKEN"
  exit 1
}

if [[ -z "$CONFIG" ]];then
  echo "CONFIG is not set"
  usage
fi

if [[ -z "$AWS_PROFILE" ]] && ([[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]]);then
  echo "AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are not set"
  usage
fi

VARS=("CUSTOMER_KEY" "DCOS_USERNAME" "DCOS_PASSWORD" "DOCKER_EMAIL_LOGIN" "DOCKER_REGISTRY_AUTH_TOKEN")
for i in "${VARS[@]}"; do
  if [[ -z "${!i}" ]];then
    echo "$i is not set"
    usage
  fi
done

for i in "${VARS[@]}"; do
  var=$i
  val=$(echo "$i" | awk '{print tolower($0)}')
  export TF_VAR_$val=${!var}
done

parse_args()
{
  while getopts ":s:d:" opt "$@"; do
    case "$opt" in
      d) DELETE_S3=($OPTARG) ;;
      s) set -f
         IFS=,
         STACKS=($OPTARG) ;;
      :) error "option -$OPTARG requires an argument." ;;
      \?) error "unknown option: -$OPTARG" ;;
    esac
  done
}

delete_buckets() {
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
}

parse_args "$@"

AWS_DCOS_STACK_BUCKET=$(awk -F\" '/^dcos_stack_bucket/{print $2}'  "environments/$CONFIG.tfvars")
AWS_DCOS_APPS_BUCKET=$(awk -F\" '/^dcos_apps_bucket/{print $2}'  "environments/$CONFIG.tfvars")

if [[ "$DELETE_S3" = "true" ]];then
  read -p "Are you sure you want to delete your S3 Buckets? [y/n] " yn
  case $yn in
      [Yy]* ) echo "Deleting S3 buckets"; delete_buckets;;
      [Nn]* ) echo "You can prevent the deletion of S3 buckets by not specifying the '-d true' option"; exit 0;;
      * ) echo "Please provide a yes or no answer."
  esac
fi

export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

CREATE_VPC=$(awk -F\" '/^create_vpc/{print $2}'  "environments/$CONFIG.tfvars")
CREATE_IAM=$(awk -F\" '/^create_iam/{print $2}'  "environments/$CONFIG.tfvars")
ONLY_PUBLIC=$(awk -F\" '/^only_public/{print $2}'  "environments/$CONFIG.tfvars")
ONLINE_PREDICTION=$(awk -F\" '/^online_prediction/{print $2}'  "environments/$CONFIG.tfvars")

if [[ "$CREATE_IAM" != "true" ]];then
  if [[ -z "$APPS_AWS_ACCESS_KEY_ID" ]] || [[ -z "$APPS_AWS_SECRET_ACCESS_KEY" ]];then
    echo "App user access keys are not set"
    exit 1
  fi

  export TF_VAR_apps_access_key=$APPS_AWS_ACCESS_KEY_ID
  export TF_VAR_apps_secret_key=$APPS_AWS_SECRET_ACCESS_KEY
fi

if [[ -z $STACKS ]]; then
  STACKS=()

  if [[ "$ONLINE_PREDICTION" = "true" ]];then
    STACKS+=("online_prediction")
  fi

  STACKS+=("platform" "redshift")

  if [[ "$ONLY_PUBLIC" != "true" ]];then
    STACKS+=("nat")
  fi

  STACKS+=("base")

  if [[ "$CREATE_IAM" = "true" ]];then
    STACKS+=("iam")
  else
    ./terraform.sh state-rm $CONFIG iam ""
  fi

  if [[ "$DELETE_S3" = "true" ]];then
    STACKS+=("s3_buckets")
  else
    ./terraform.sh state-rm $CONFIG s3_buckets ""
  fi

  if [[ "$CREATE_VPC" = "true" ]];then
    STACKS+=("vpc")
  else
    ./terraform.sh state-rm $CONFIG vpc ""
  fi
fi

CLUSTER_NAME=$(awk -F\" '/^cluster_name/{print $2}'  "environments/$CONFIG.tfvars")
if $(dcos cluster list | grep -q "$CLUSTER_NAME") && [[ "${STACKS[@]}" =~ "platform" ]]; then
  echo "removing cluster from CLI"
  dcos cluster remove "$CLUSTER_NAME"
fi

for i in "${STACKS[@]}"; do
  echo "Destroying $i"
  sh terraform.sh init $CONFIG "$i"
  sh terraform.sh destroy $CONFIG "$i"
done

echo "Artifacts destroyed."