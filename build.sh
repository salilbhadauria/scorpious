#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config> <aws_profile> or (<aws_access_key_id> and <aws_secret_access_key>) <customer_key> <dcos_username> <dcos_password> [args...]"
  echo " e.g.: $0 integration default XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX deepcortex password "
  exit 1
}

export TF_VAR_dcos_password=$DCOS_PASSWORD
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

sh terraform_init_backend.sh $CONFIG

#IMAGES=("captain" "bootstrap" "master" "slave")
#for i in "${IMAGES[@]}"; do
#  sh packer.sh $i $CONFIG;
#done

STACKS=("iam" "vpc" "redshift" "platform")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done

ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")
OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")
NUM_SLAVES=$(awk -F\" '/^slave_asg_max_size/{print $2}'  "environments/$CONFIG.tfvars")
NUM_PUB_SLAVES=$(awk -F\" '/^public_slave_asg_max_size/{print $2}'  "environments/$CONFIG.tfvars")
DCOS_NODES=$((NUM_SLAVES + NUM_PUB_SLAVES))

DCOS_MASTER_ELB=$(aws elb describe-load-balancers --load-balancer-names=$OWNER-$ENVIRONMENT-master-elb --output=text --query "LoadBalancerDescriptions[*].DNSName")
BAILE_ELB=$(aws elb describe-load-balancers --load-balancer-names=$OWNER-$ENVIRONMENT-baile-elb --output=text --query "LoadBalancerDescriptions[*].DNSName")

NEXT_WAIT_TIME=0
MAX_WAIT_TIMES=20
SLEEP_SECONDS=60
MASTER_CONNECTED=false

echo "*** Waiting for DeepCortex to finish building and initializing."
echo "*** This may take up to $(( MAX_WAIT_TIMES * SLEEP_SECONDS / 60 )) minutes..."

while [ ${NEXT_WAIT_TIME} -lt ${MAX_WAIT_TIMES} ]; do

  if $(curl --output /dev/null --silent --head --fail http://$DCOS_MASTER_ELB:/); then  
    if [ $MASTER_CONNECTED == false ]; then
      echo "Connecting to the DC/OS cluster..." 
      dcos cluster setup http://${DCOS_MASTER_ELB} --username=${DCOS_USERNAME} --password-env=DCOS_PASSWORD --no-check
      echo "Connected to cluster." 
      MASTER_CONNECTED=true   
    fi
    NODES=$(dcos node | grep agent | wc -l)
    if [ $NODES -lt $DCOS_NODES ]; then
      echo "There are currenlty ${NODES} nodes connected. Waiting for $(( DCOS_NODES - NODES )) more node(s) to connect..."
    else
      echo "All nodes connected."
      SERVICES=$(dcos marathon deployment list | grep -q scale)
      echo "Starting deployment and initialization of services..."
      until $(dcos marathon deployment list | grep -q aries); do sleep 5; done
      if $(dcos marathon deployment list | grep -q scale); then
        echo "Waiting for all services to deploy and initialize..."   
      else 
        echo "All services deployed."
        if $(curl --output /dev/null --silent --head --fail http://$BAILE_ELB:/); then
          sleep 30
          echo "*** You can now access DeepCortex at: http://$BAILE_ELB."
          exit 0
        else
          echo "Waiting for DeepCortex to initialize..."
        fi      
      fi
    fi 
  else
    echo "Waiting to connnect to Master node."
  fi    
  
  echo "sleep"
  (( NEXT_WAIT_TIME++ )) && sleep ${SLEEP_SECONDS}

done

echo "Failed due to timeout"
abort
