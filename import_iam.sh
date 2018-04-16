#!/bin/bash

CONFIG=$1

if [ ${#} -ne 1 ]; then
  echo "Must supply an arguement for CONFIG"
fi

OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")
ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")

# init vpc
./terraform.sh init $CONFIG iam

# import IAM app user
./terraform.sh import $CONFIG iam aws_iam_user.app $OWNER-$ENVIRONMENT-app

# import bastion instance profile
./terraform.sh import $CONFIG iam aws_iam_instance_profile.bastion_instance_profile $OWNER-$ENVIRONMENT-bastion_instance_profile

# import bootstrap instance profile
./terraform.sh import $CONFIG iam aws_iam_instance_profile.bootstrap_instance_profile $OWNER-$ENVIRONMENT-bootstrap_instance_profile

# import master instance profile
./terraform.sh import $CONFIG iam aws_iam_instance_profile.master_instance_profile $OWNER-$ENVIRONMENT-master_instance_profile

# import slave instance profile
./terraform.sh import $CONFIG iam aws_iam_instance_profile.slave_instance_profile $OWNER-$ENVIRONMENT-slave_instance_profile

# import captain instance profile
./terraform.sh import $CONFIG iam aws_iam_instance_profile.captain_instance_profile $OWNER-$ENVIRONMENT-captain_instance_profile

# refresh to obtain outputs
./terraform.sh refresh $CONFIG iam