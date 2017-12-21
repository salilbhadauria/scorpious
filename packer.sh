#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <image> <config_file> [args...]"
  echo " e.g.: $0 bootstrap integration"
  echo "All images require environment variable AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) to be set"
  echo "Bootstrap image requires environment variables CUSTOMER_KEY, DCOS_USERNAME, and DCOS_PASSWORD to be set"
  exit 1
}

if [ ${#} -ne 2 ]; then
  usage
fi

export IMAGE=$1  ; shift
export CONFIG=$1 ; shift

export AMI=$(awk -F\"      '/^packer_base_ami/{print $2}'      "environments/$CONFIG.tfvars")
export REGION=$(awk -F\"   '/^aws_region/{print $2}'           "environments/$CONFIG.tfvars")
export SSH_USER=$(awk -F\" '/^packer_ssh_user/{print $2}'      "environments/$CONFIG.tfvars")
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}' "environments/$CONFIG.tfvars")

export PACKER_VPC_ID=$(awk -F\" '/^vpc_id/{print $2}'  "environments/$CONFIG.tfvars")
export PACKER_SUBNET_ID=$(awk -F\" '/^subnet_id_1/{print $2}'  "environments/$CONFIG.tfvars")

export MASTER_XVDE_SIZE=$(awk -F\" '/^master_xvde_size/{print $2}'  "environments/$CONFIG.tfvars")
export MASTER_XVDF_SIZE=$(awk -F\" '/^master_xvdf_size/{print $2}'  "environments/$CONFIG.tfvars")
export MASTER_XVDG_SIZE=$(awk -F\" '/^master_xvdg_size/{print $2}'  "environments/$CONFIG.tfvars")
export MASTER_XVDH_SIZE=$(awk -F\" '/^master_xvdh_size/{print $2}'  "environments/$CONFIG.tfvars")

export SLAVE_XVDE_SIZE=$(awk -F\" '/^slave_xvde_size/{print $2}'  "environments/$CONFIG.tfvars")
export SLAVE_XVDF_SIZE=$(awk -F\" '/^slave_xvdf_size/{print $2}'  "environments/$CONFIG.tfvars")
export SLAVE_XVDG_SIZE=$(awk -F\" '/^slave_xvdg_size/{print $2}'  "environments/$CONFIG.tfvars")
export SLAVE_XVDH_SIZE=$(awk -F\" '/^slave_xvdh_size/{print $2}'  "environments/$CONFIG.tfvars")

export AWS_REGION="${REGION:-us-east-1}"

if [ -z "$AWS_PROFILE" ];then
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ];then
    echo "AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are not set"
    usage
  fi  
fi

if [ -z "$CUSTOMER_KEY" ] && [ "${IMAGE}" = "bootstrap" ];then
  echo "Error: CUSTOMER_KEY is not set"
  usage
fi

if [ -z "$DCOS_USERNAME" ] && ([ "${IMAGE}" = "bootstrap" ] || [ "${IMAGE}" = "captain" ]);then
  echo "Error: DCOS_USERNAME is not set"
  usage
fi

if [ -z "$DCOS_PASSWORD" ] && ([ "${IMAGE}" = "bootstrap" ] || [ "${IMAGE}" = "captain" ]);then
  echo "Error: DCOS_PASSWORD is not set"
  usage
fi

PWD=$(pwd)
FILE="$PWD/ansible/roles/deployer/files/id_rsa"
if [ -f "$FILE" ]
then
	echo "SSH Key already created"
else
  echo "Creating ssh key for deployer user"
	ssh-keygen -t rsa -N "" -f $FILE
fi

get_git_describe_with_dirty() {
  # produces abbrev'ed SHA1 of HEAD with possible -dirty suffix

  local D=$(git describe --all --dirty)
  local SHA1=$(git show-ref -s --abbrev refs/${D%-dirty})
  echo ${D/${D%-dirty}/$SHA1}
}

: ${BUILD_UUID:=$(uuidgen)}
GIT_COMMIT=1

run_packer() {
  set -x
  local UUID=$1       ; shift
  local GIT_COMMIT=$2 ; shift
  local opts

  #(( $# >= 1 ))
  [ "${IMAGE}" != "all" ] && opts="-only=${IMAGE}"
  packer build \
      -var "git_commit=$GIT_COMMIT" \
      -var "build_uuid=$UUID" \
      -var "image_name=$IMAGE" \
      "$@" ${opts} packer/all.json
  set +x
}

run_packer $BUILD_UUID $GIT_COMMIT "$@"
