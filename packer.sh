#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <image> <config_file> [args...]"
  echo " e.g.: $0 bootstrap integration"
  echo "All images requires environment variable AWS_PROFILE to be set"
  echo "Bootstrap image requires environment variable CUSTOMER_KEY, SUPERUSER_PASSWORD_HASH and DOCKER_REGISTRY_AUTH_TOKEN to be set"
  exit 1
}

if [ ${#} -ne 2 ]; then
  usage
fi

if [ -z "$2" ];then
  usage
fi

if [ -z "$2" ];then
  usage
fi

if [ -z "$AWS_PROFILE" ];then
  echo "AWS_PROFILE is not set"
  usage
fi

if [ -z "$CUSTOMER_KEY" ] && [ $1 = "bootstrap" ];then
  echo "Error: CUSTOMER_KEY is not set"
  usage
fi

if [ -z "$DCOS_USERNAME" ] && ([ $1 = "bootstrap" ] || [ $1 = "captain" ]);then
  echo "Error: DCOS_USERNAME is not set"
  usage
fi

if [ -z "$DCOS_PASSWORD" ] && ([ $1 = "bootstrap" ] || [ $1 = "captain" ]);then
  echo "Error: DCOS_PASSWORD is not set"
  usage
fi

if [ -z "$DOCKER_REGISTRY_AUTH_TOKEN" ] && ([ $1 = "bootstrap" ] || [ $1 = "captain" ]);then
  echo "Error: DOCKER_REGISTRY_AUTH_TOKEN is not set"
  usage
fi

export IMAGE=$1
export CONFIG=$2
export AMI=$(awk -F\" '/^packer_base_ami/{print $2}'  "environments/$CONFIG.tfvars")
export REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")
export SSH_USER=$(awk -F\" '/^packer_ssh_user/{print $2}'  "environments/$CONFIG.tfvars")
shift 2

export AWS_REGION="${AWS_REGION:-us-east-2}"

get_git_describe_with_dirty() {
  # produces abbrev'ed SHA1 of HEAD with possible -dirty suffix

  local D=$(git describe --all --dirty)
  local SHA1=$(git show-ref -s --abbrev refs/${D%-dirty})
  echo ${D/${D%-dirty}/$SHA1}
}

: ${BUILD_UUID:=$(uuidgen)}
GIT_COMMIT=$(get_git_describe_with_dirty)

run_packer() {
  set -x
  local UUID=$1 GIT_COMMIT=$2; shift 2
  (( $# >= 1 ))
  packer build \
      -var "git_commit=$GIT_COMMIT" \
      -var "build_uuid=$UUID" \
      -var "image_name=$IMAGE" \
      "$@" packer/aws.json
  set +x
}

run_packer $BUILD_UUID $GIT_COMMIT "$@"
