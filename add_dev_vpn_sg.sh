#!/bin/bash

if [[ -z "$AWS_PROFILE" ]] && ([[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]]);then
  echo "AWS_PROFILE or access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are not set"
fi

function getSgByName () {
    local sg_name
    sg_name="$1"

    SG=$(aws ec2 describe-security-groups --filter Name=tag-key,Values=Name Name=tag-value,Values=${sg_name} --query 'SecurityGroups[*].{ID:GroupId}' | grep -o 'sg-[a-z,0-9]*')

    echo "$SG"
}

ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")
OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")

vpn_sg="${1:-openVPN-dev}"

DC_VPN_SG="$(getSgByName $vpn_sg)"
echo "openVPN sg group: $DC_VPN_SG"

DCOS_SG="$(getSgByName dcos-stack-$OWNER-$ENVIRONMENT)"
echo "dcos-stack sg group: $DCOS_SG"

aws ec2 authorize-security-group-ingress --group-id ${DCOS_SG} --protocol all --port all --source-group ${DC_VPN_SG}
echo "Access to DC/OS machines from Dev VPN has been granted."

BAILE_LB_SG="$(getSgByName baile-elb-in-$OWNER-$ENVIRONMENT)"
echo "baile-LB sg group: $BAILE_LB_SG"

aws ec2 authorize-security-group-ingress --group-id ${BAILE_LB_SG} --protocol all --port all --source-group ${DC_VPN_SG}
echo "Access to the DeepCortex UI from Dev VPN has been granted."

DCOS_LB_SG="$(getSgByName master-elb-in-$OWNER-$ENVIRONMENT)"
echo "baile-LB sg group: $DCOS_LB_SG"

aws ec2 authorize-security-group-ingress --group-id ${DCOS_LB_SG} --protocol all --port all --source-group ${DC_VPN_SG}
echo "Access to the DC/OS UI from Dev VPN has been granted."
