#!/usr/bin/env bash
set +e

# optional arguments:
# -b: shutdown boostrap - can be set to true destroy bootstrap node after the cluster deploys
# -g: gpu on start - can be set to false to exclude spinning up a gpu node after the cluster deploys
# -m: deploy mode - can be set to simple to exclude download of DC/OS cli and extra output
# -s: stacks - a list of comma separated values to overwrite which terraform stacks to build
# -p: packer - can be set to false to exclude packer builds

usage() {
  echo "Usage: Must set environment variables for CONFIG, AWS_PROFILE or (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY), CUSTOMER_KEY, DCOS_USERNAME, DCOS_PASSWORD"
  exit 1
}

VARS=("CONFIG" "CUSTOMER_KEY" "DCOS_USERNAME" "DCOS_PASSWORD")
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

parse_args()
{
  while getopts ":b:d:g:m:p:s:" opt "$@"; do
    case "$opt" in
      b) SHUTDOWN_BOOTSTRAP="$OPTARG" ;;
      g) GPU_ON_START="$OPTARG" ;;
      m) DEPLOY_MODE="$OPTARG" ;;
      p) PACKER="$OPTARG" ;;
      s) set -f
         IFS=,
         STACKS=($OPTARG) ;;
      :) error "option -$OPTARG requires an argument." ;;
      \?) error "unknown option: -$OPTARG" ;;
    esac
  done
}

export TF_VAR_dcos_password=$DCOS_PASSWORD
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

sh terraform_init_backend.sh $CONFIG

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")
STACKS=("iam" "vpc" "redshift" "platform" "online_prediction")

ONLINE_PREDICTION=$(awk -F\" '/^online_prediction/{print $2}'  "environments/$CONFIG.tfvars")
if [[ "$ONLINE_PREDICTION" != "true" ]];then
  STACKS=("iam" "vpc" "redshift" "platform")
fi

parse_args "$@"

if [[ "$PACKER" != "false" ]];then
  sh packer.sh all $CONFIG;
fi

for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG "$PREFIX$i";
  sh terraform.sh plan $CONFIG "$PREFIX$i";
  sh terraform.sh apply $CONFIG "$PREFIX$i";
done

if [[ "$DEPLOY_MODE" != "simple" ]];then

  ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")
  OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")
  CLUSTER_NAME=$(awk -F\" '/^cluster_name/{print $2}'  "environments/$CONFIG.tfvars")
  NUM_SLAVES=$(awk -F\" '/^slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
  NUM_PUB_SLAVES=$(awk -F\" '/^public_slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
  NUM_GPU_SLAVES=$(awk -F\" '/^gpu_slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
  DCOS_NODES=$((NUM_SLAVES + NUM_PUB_SLAVES + NUM_GPU_SLAVES))
  DCOS_SERVICES=$(awk -F\" '/^dcos_services/{print $2}'  "environments/$CONFIG.tfvars")

  DCOS_MASTER_ELB=$(aws elb describe-load-balancers --load-balancer-names=$OWNER-$ENVIRONMENT-master-elb --output=text --query "LoadBalancerDescriptions[*].DNSName")
  BAILE_ELB=$(aws elb describe-load-balancers --load-balancer-names=$OWNER-$ENVIRONMENT-baile-elb --output=text --query "LoadBalancerDescriptions[*].DNSName")

  echo "*** Waiting for DeepCortex to finish building and initializing."
  echo "*** This may take up to 90 minutes..."
  echo ""

  COUNT=0
  echo "Deploying Master node."
  echo "If step lasts longer than 30 minutes there may be an issue with the node."
  echo "To attempt a fix, terminate the Master node in AWS so the auto scaling group can deploy a new one."
  echo ""
  until $(curl --output /dev/null --silent --head --fail http://$DCOS_MASTER_ELB:/); do
    sleep 60
    COUNT=$((COUNT+1))
    echo "Master node has been deploying for $COUNT minutes."
  done
  echo ""
  echo "Master node deployed."
  echo "Connecting to the DC/OS cluster..."
  dcos cluster setup http://${DCOS_MASTER_ELB} --username=${DCOS_USERNAME} --password-env=DCOS_PASSWORD --no-check
  dcos cluster attach "$CLUSTER_NAME"
  echo "Connected to cluster."
  echo ""
  echo "*** You can now access the Mater Node at http://${DCOS_MASTER_ELB}"
  echo ""

  COUNT=0
  echo "Deploying public and private slave nodes."
  echo "If step lasts longer than 30 minutes there may be an issue with one or more of the nodes."
  echo "To attempt a fix, navigate to the nodes section of the DC/OS UI: http://$DCOS_MASTER_ELB/#/nodes."
  echo "All IPs listed are the nodes that have already connected."
  echo "Terminate the unconnected nodes in AWS so the auto scaling group can deploy new ones."
  echo ""
  NODES=$(dcos node | grep agent | wc -l)
  until [[ $NODES -eq $DCOS_NODES ]]; do
    echo "There are currently ${NODES} nodes connected. Waiting for $(( DCOS_NODES - NODES )) more node(s) to connect..."
    sleep 60
    COUNT=$((COUNT+1))
    echo "Nodes have been deploying for $COUNT minutes."
    NODES=$(dcos node | grep agent | wc -l)
  done
  echo "All nodes connected."
  echo ""

  COUNT=0
  echo "Deploying all services."
  echo "If step lasts longer than 30 minutes there may be an issue with the captain node or one of the services."
  echo "To attempt a fix, navigate to the services section of the DC/OS UI: http://$DCOS_MASTER_ELB/#/services/overview."
  echo "If there are no services being deployed, there is likely an issue with the captain node."
  echo "Terminate the captain node in AWS so the auto scaling group can deploy a new one."
  echo ""
  SERVICES_DEPLOYING=$(dcos marathon app list | grep scale | wc -l)
  SERVICES_RUNNING=$(dcos marathon app list | grep False | wc -l)
  until [[ $SERVICES_DEPLOYING -eq 0 ]] && [[ $SERVICES_RUNNING -eq $DCOS_SERVICES ]]; do
    SERVICES_LEFT=$((DCOS_SERVICES - SERVICES_RUNNING))
    echo "There are currently $SERVICES_LEFT services still deploying..."
    sleep 60
    COUNT=$((COUNT+1))
    echo "Services have been deploying for $COUNT minutes."
    SERVICES_DEPLOYING=$(dcos marathon app list | grep scale | wc -l)
    SERVICES_RUNNING=$(dcos marathon app list | grep False | wc -l)
  done
  echo "All services deployed."
  echo ""

  until $(curl --output /dev/null --silent --head --fail http://$BAILE_ELB); do
    sleep 30
  done
  echo "*** You can now access DeepCortex at: http://$BAILE_ELB"

  if [[ "$GPU_ON_START" != "false" ]];then
    echo "Starting up GPU node"
    bash set_capacity.sh gpu-slave 1

    COUNT=0
    echo "Deploying gpu node."
    echo "If step lasts longer than 30 minutes there may be an issue with the node."
    echo "To attempt a fix, terminate the GPU node in AWS so the auto scaling group can deploy a new one."
    echo ""
    NODES=$(dcos node | grep agent | wc -l)
    until [[ $NODES -eq $((DCOS_NODES + 1)) ]]; do
      echo "Waiting for the GPU node to connect..."
      sleep 60
      COUNT=$((COUNT+1))
      echo "GPU node has been deploying for $COUNT minutes."
      NODES=$(dcos node | grep agent | wc -l)
    done
    echo "GPU node connected"
  fi

  if [[ "$SHUTDOWN_BOOTSTRAP" == "true" ]];then
    echo "Shutting down bootstrap node"
    bash set_capacity.sh bootstrap 0
  fi

  echo "*** Deployment complete"
fi
