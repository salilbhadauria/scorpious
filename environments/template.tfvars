
### You must fill in the following varibles before executing the deployment.
# Remove the <> symbols before deploying.

# the account ID of the AWS account you will deploy to
account                         = <"YOUR_AWS_ACCOUNT_ID">

# the public ssh key for the key you would like to use to access the DC/OS machines used for DeepCortex
ssh_public_key                  = <"YOUR_SSH_PUBLIC_KEY">

# the CIDR for a VPN or machine IP that should be able to access DeepCortex
access_cidr                     = <"YOUR_ACCESS_CIDR">
deploy_cidr                     = <"YOUR_DEPLOY_CIDR">

### You may change any of the below names if you choose, otherwise the defaults we be used.

# the name of the S3 buckets used for storing terraform artifacts, storing DeepCortex data, and storing DC/OS data
tf_bucket                       = "deepcortex-dev-terraform"
dcos_apps_bucket                = "deepcortex-dev-dcos-apps"
dcos_stack_bucket               = "deepcortex-dev-dcos-backend"

# the tags that will be applied to the infrastructure (environment, owner, usage)
environment                     = "dev"
tag_owner                       = "deepcortex"
tag_usage                       = "dev"

# the name of the redshfit cluster
redshift_cluster_name           = "deepcortex-dev-redshift"


### DO NOT CHANGE ANYTHING BELOW THIS LINE

# Packer
packer_base_ami                 = "ami-6f61e60e"
main_user                 = "ec2-user"

# Terraform
# VPC
aws_region                      = "us-gov-west-1"
vpc_cidr                        = "10.0.0.0/16"
azs                             = [ "1a", "1b" ]
public_subnets                  = [ "10.0.1.0/24", "10.0.2.0/24" ]
private_subnets                 = [ "10.0.11.0/24", "10.0.12.0/24" ]
private_subnets_egress          = [ "10.0.21.0/24", "10.0.22.0/24" ]
bastion_ami_id                  = "ami-b2d056d3"
nat_ami_id                      = "ami-fe991b9f"

# Platform
bootstrap_asg_desired_capacity  = "1"
bootstrap_asg_min_size          = "1"
bootstrap_asg_max_size          = "1"
bootstrap_elb_dns_name          = "bootstrap"
s3_prefix                       = "deepcortex"
cluster_name                    = "deepcortex"

master_asg_desired_capacity     = "1"
master_asg_min_size             = "1"
master_asg_max_size             = "1"
master_elb_dns_name             = "master"

# mesos, docker, volume0, log
master_xvde_size                = "50"
master_xvdf_size                = "50"
master_xvdg_size                = "50"
master_xvdh_size                = "50"

slave_asg_desired_capacity     = "3"
slave_asg_min_size             = "1"
slave_asg_max_size             = "3"

# mesos, docker, volume0, log
slave_xvde_size                = "100"
slave_xvdf_size                = "50"
slave_xvdg_size                = "100"
slave_xvdh_size                = "50"

public_slave_asg_desired_capacity  = "1"
public_slave_asg_min_size          = "1"
public_slave_asg_max_size          = "1"

captain_asg_desired_capacity  = "1"
captain_asg_min_size          = "1"
captain_asg_max_size          = "1"


# Redshift
redshift_family = "redshift-1.0"
redshift_database_name = "dev"
redshift_master_username = "deepcortex"
redshift_node_type = "dc1.large"
redshift_cluster_type = "multi-node"
redshift_number_of_nodes = 2
redshift_encrypted = false
redshift_skip_final_snapshot = true
