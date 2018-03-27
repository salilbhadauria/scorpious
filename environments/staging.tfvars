### You must fill in the following varibles before executing the deployment.
# Remove the <> symbols before deploying.

# the account ID of the AWS account you will deploy to
account                         = "068078214683"

# the name of the AWS region e.g. "us-east-1"
aws_region                      = "us-east-1"

# the comma separated list of availability zones e.g. [ "1a", "1b" ]
azs                             = [ "1a", "1b" ]

# the arn value for the region being used
# ex: in AWS gov cloud a polic resources is written as "arn:aws-us-gov:iam::aws:policy"
# the arn value you would supply for AWS gov cloud is "aws-us-gov"
arn                             = "aws"

# the S3 endpoint for the region being used e.g. "s3-us-gov-west-1.amazonaws.com"
s3_endpoint                     = "s3.amazonaws.com"

# the ami id for the machine that will serve as the bastion (can be CentOS or Amazon Linux)
bastion_ami_id                  = "ami-26ebbc5c"

# the ami id for the machines that will run DeepCortex (should be a CentOS 7.4 ami)
packer_base_ami                 = "ami-26ebbc5c"

# operating system for DeepCortex machines (centos or rhel)
machine_os                      = "rhel"

# the default ssh user for the above ami (likely centos for CentOS machines, but could be ec2-user so make sure to check the ami you are using)
main_user                       = "ec2-user"

# the VPC ID of the VPC you will launch DeepCortex into
vpc_id                          = "vpc-a7d785c1"

# the VPC S3 Endpoint of the VPC you will launch DeepCortex into
vpce_id                         = "vpce-a45a91cd"

# the VPC CIDR block you will launch DeepCortex into
vpc_cidr                        = "10.15.0.0/16"

# the subnet IDs of the subnets you will launch DeepCortex into
subnet_id_1                     = "subnet-3715ff7f"
subnet_id_2                     = "subnet-5e497805"

# the public ssh key for the key you would like to use to access the DC/OS machines used for DeepCortex
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChaCuONxHDjufsY9RCGCkJ+LeB69/A/Y9Rn4VmuI+szLRbvzlIXVa7lY5062ps9IueQVSZGgtkTapXssyuLoCYi1ujK24Sui5fxNFMd9aYqpKtjGAhD25IkGlq+Vy/ZJn8CVFguJsef/dxzcWSOOlWlZ1TUY/cmiHMkiJL624Km3lDrLNbDQprH7ERuXhI+EbBzeufrN635A7gRaenX2z1Mkmoej8SUvCbGfT1S0168HIIOVb3MdIkkZVG/Y9QY2cOqkF+nOhIMZ4AkyT+a2EGc7o6y20hv4iv4r9gfv3+sLIHSha0t6hn3V7hz+4BMpFtNheHAbmS7mVTZlorD4i7 deepcortex-master-dev"

# the CIDR for a VPN or machine IP that should be able to access DeepCortex
access_cidr                     = "205.251.70.6/32"

# the CIDR for the IP of the machine that is running the deployment container
deploy_cidr                     = "205.251.70.6/32"

# specify if Public MSTAR and CAD data should be uploaded to the default DeepCortex S3 bucket
upload_datasets                 = "true"

# extra ssh keys: fill out the following section if you wish for the DC/OS machines to have additional
# ssh keys added to allow other users to ssh to those machines with a key other than the one provided above

# set to true if you'd like to add additional keys
download_ssh_keys               = "true"

# specify the location of the file in S3 that contains the list of public keys you'd like to add to each machine
ssh_keys_s3_bucket              = "s3://artifacts.dev.deepcortex.ai/configurations/ssh/keys.public"

### You may change any of the below names if you choose, otherwise the defaults we be used.

# the name of the S3 buckets used for storing terraform artifacts, storing DeepCortex data, and storing DC/OS data
tf_bucket                       = "falcon-deepcortex-staging-terraform"
dcos_apps_bucket                = "falcon-deepcortex-staging-dcos-apps"
dcos_stack_bucket               = "falcon-deepcortex-staging-dcos-backend"

# the tags that will be applied to the infrastructure (environment, owner, usage)
# environment and owner can only be a combined 17 characters
environment                     = "staging"
tag_owner                       = "deepcortex"
tag_usage                       = "staging"

# the name of the redshfit cluster
redshift_cluster_name           = "falcon-deepcortex-staging-redshift"


### DO NOT CHANGE ANYTHING BELOW THIS LINE

# version of DC/OS
dcos_version                    = "1.10.2"

# public vs private baile
baile_access                    = "private"

# enable online prediction (true/false)
online_prediction               = "true"

# true or false for downloading latest files (frontend and mstar) from S3 rather than using files in the docker container
download_from_s3                = "true"

# prefix for terraform templates
prefix                          = "exvpc_"

# Platform
bootstrap_asg_desired_capacity  = "1"
bootstrap_asg_min_size          = "0"
bootstrap_asg_max_size          = "1"
bootstrap_elb_dns_name          = "bootstrap"
s3_prefix                       = "deepcortex"
cluster_name                    = "deepcortex-staging"

master_asg_desired_capacity     = "1"
master_asg_min_size             = "1"
master_asg_max_size             = "1"

# mesos, docker, log
master_xvde_size                = "50"
master_xvdf_size                = "20"
master_xvdh_size                = "50"

slave_asg_desired_capacity      = "3"
slave_asg_min_size              = "1"
slave_asg_max_size              = "3"

# mesos, docker, volume0, log
slave_xvde_size                 = "150"
slave_xvdf_size                 = "100"
slave_xvdg_size                 = "100"
slave_xvdh_size                 = "50"

gpu_slave_asg_desired_capacity  = "0"
gpu_slave_asg_min_size          = "0"
gpu_slave_asg_max_size          = "1"

# mesos, docker, log
gpu_slave_xvde_size             = "50"
gpu_slave_xvdf_size             = "50"
gpu_slave_xvdh_size             = "50"

public_slave_asg_desired_capacity  = "1"
public_slave_asg_min_size          = "1"
public_slave_asg_max_size          = "1"

# mesos, docker, log
public_slave_xvde_size             = "50"
public_slave_xvdf_size             = "50"
public_slave_xvdh_size             = "50"

captain_asg_desired_capacity       = "1"
captain_asg_min_size               = "0"
captain_asg_max_size               = "1"


# Redshift
redshift_family = "redshift-1.0"
redshift_database_name = "dev"
redshift_master_username = "deepcortex"
redshift_node_type = "dc1.large"
redshift_cluster_type = "multi-node"
redshift_number_of_nodes = 2
redshift_encrypted = false
redshift_skip_final_snapshot = true

# Application Docker Image Versions
argo_docker_image_version = "0.0.0-0a7e019180ecf897f38f085f63918373a89c11fc"
aries_docker_image_version = "0.0.0-8d38fd1867462ecc8b7ae874037d3b649d245123"
baile_docker_image_version = "v1.0.9"
baile_haproxy_docker_image_version = "v1.0"
cortex_docker_image_version = "1.0.26-13-ge4032a3"
logstash_docker_image_version = "latest"
orion_docker_image_version = "0.0.0-48b96e66c4741a821206b13f449139fdb8086bba"
job_master_docker_image = "deepcortex/cortex-job-master:0.9.3-287-g493f13e"
pegasus_docker_image_version = "0.0.1-SNAPSHOT-27-g665fc42"
rmq_docker_image_version = "latest"
taurus_docker_image_version = "0.0.0-708ad97786f2e03aba793b467aebf85415c9af21"
um_docker_image_version = "v1.0"
salsa_version = "falcon"

# Number of total DC/OS services
dcos_services = "15"
