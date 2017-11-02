#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <image> [args...]"
  echo " e.g.: $0 base"
  echo "Requires environment variable AWS_PROFILE to be set"
  exit 1
}

if [ -z "$1" ];then
  usage
fi

if [ -z "$AWS_PROFILE" ];then
  echo "AWS_PROFILE is not set"
  usage
fi

export IMAGE=$1
shift 1

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
