#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <config_file> [args...]"
  echo " e.g.: $0 integration "
  exit 1
}

export TF_VAR_dcos_password="${DCOS_PASSWORD}"
export AWS_DEFAULT_REGION=$(awk -F\" '/^aws_region/{print $2}'  "environments/$CONFIG.tfvars")

PREFIX=$(awk -F\" '/^prefix/{print $2}'  "environments/$CONFIG.tfvars")

STACKS=("${PREFIX}iam" "${PREFIX}vpc" "${PREFIX}redshift" "${PREFIX}platform" "${PREFIX}online_prediction")
for i in "${STACKS[@]}"; do
  sh terraform.sh init $CONFIG $i;
  sh terraform.sh plan $CONFIG $i;
  sh terraform.sh apply $CONFIG $i;
done

curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.10/dcos -o dcos &&
mv dcos /usr/local/bin &&
chmod +x /usr/local/bin/dcos

ENVIRONMENT=$(awk -F\" '/^environment/{print $2}'  "environments/$CONFIG.tfvars")
OWNER=$(awk -F\" '/^tag_owner/{print $2}'  "environments/$CONFIG.tfvars")
NUM_SLAVES=$(awk -F\" '/^slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
NUM_PUB_SLAVES=$(awk -F\" '/^public_slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
NUM_GPU_SLAVES=$(awk -F\" '/^gpu_slave_asg_desired_capacity/{print $2}'  "environments/$CONFIG.tfvars")
DCOS_NODES=$((NUM_SLAVES + NUM_PUB_SLAVES + NUM_GPU_SLAVES))
DCOS_SERVICES=12

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
NODES=0
until [ $NODES -eq $DCOS_NODES ]; do
  NODES=$(dcos node | grep agent | wc -l)
  echo "There are currently ${NODES} nodes connected. Waiting for $(( DCOS_NODES - NODES )) more node(s) to connect..."
  sleep 60
  COUNT=$((COUNT+1))
  echo "Nodes have been deploying for $COUNT minutes."
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
SERVICES_DEPLOYING=0
SERVICES_RUNNING=0
until [ $SERVICES_DEPLOYING -eq 0 ] && [ $SERVICES_RUNNING -eq 12 ]; do
  SERVICES_DEPLOYING=$(dcos marathon app list | grep scale | wc -l)
  SERVICES_RUNNING=$(dcos marathon app list | grep False | wc -l)
  SERVICES_LEFT=$((12 - SERVICES_RUNNING))
  echo "There are currently $SERVICES_LEFT services still deploying..."
  sleep 60
  COUNT=$((COUNT+1))
  echo "Services have been deploying for $COUNT minutes."
done
echo "All services deployed."
echo ""

until $(curl --output /dev/null --silent --head --fail http://$BAILE_ELB:/); do
  sleep 30
done
echo "*** You can now access DeepCortex at: http://$BAILE_ELB"
