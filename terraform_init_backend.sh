#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> [args...]"
  echo " e.g.: $0 integration"
  exit 1
}

if [ -z "$1" ];then
  usage
fi

export CONFIG=$1
export REGION=$(awk -F\" '/aws_region/{print $2}'  "environments/$CONFIG.tfvars")
export BUCKET=$(awk -F\" '/bucket/{print $2}'  "environments/$CONFIG.tfvars")

shift 1

OS=$(uname -a)

for i in $(find terraform -name main.tf | grep -v modules);
  do
    if [[ $OS == *"Darwin"* ]]; then
      echo "Updating: $i"
      sed -i '.bak' "s/backend \"s3\" { region = \".*\" }/backend \"s3\" { region = \"$REGION\" }/g" $i;
    else
      sed -i "s/backend \"s3\" { region = \".*\" }/backend \"s3\" { region = \"$REGION\" }/g" $i;
    fi
done

if aws s3 ls "s3://$BUCKET" 2>&1 | grep -q 'NoSuchBucket'
  then
    aws s3 mb s3://$BUCKET
else
  echo "Bucket already exits"
fi
