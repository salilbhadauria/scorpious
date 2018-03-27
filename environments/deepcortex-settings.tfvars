### You must fill in the following varibles before executing the deployment.
# Remove the <> symbols before deploying.

# the account ID of the AWS account you will deploy to e.g. 123456789
account                         = "<AWS_ACCOUNT_ID>"

# the name of the AWS region e.g. "us-east-1"
aws_region                      = "us-gov-west-1"

# the comma separated list of availability zones e.g. [ "1a", "1b" ]
azs                             = [ "1a", "1b" ]

# the arn value for the region being used
# ex: in AWS gov cloud a polic resources is written as "arn:aws-us-gov:iam::aws:policy"
# the arn value you would supply for AWS gov cloud is "aws-us-gov"
arn                             = "aws-us-gov"

# the S3 endpoint for the region being used e.g. "s3-us-gov-west-1.amazonaws.com"
s3_endpoint                     = "s3-us-gov-west-1.amazonaws.com"

# the ami id for the machine that will serve as the bastion e.g. ami-12345678 (can be CentOS or Amazon Linux)
bastion_ami_id                  = "ami-128c0873"

# the ami id for the machines that will run DeepCortex e.g. ami-12345678 (should be a CentOS 7.4 ami)
packer_base_ami                 = "ami-128c0873"

# the default ssh user for the above ami e.g. centos (likely centos for CentOS machines, but could be ec2-user so make sure to check the ami you are using)
packer_ssh_user                 = "centos"

# the VPC ID of the VPC you will launch DeepCortex into e.g. vpc-12345678
vpc_id                          = "<VPC_ID>"

# the VPC S3 Endpoint of the VPC you will launch DeepCortex into e.g. vpce-12345678
vpce_id                         = "<VPCE_ID>"

# the VPC CIDR block you will launch DeepCortex into e.g. 0.0.0.0/0
vpc_cidr                        = "<VPC_CIDR>"

# the subnet IDs of the subnets you will launch DeepCortex into e.g. subnet-12345678
subnet_id_1                     = "<SUBNET_1>"
subnet_id_2                     = "<SUBNET_2>"

# the public ssh key for the key you would like to use to access the DC/OS machines used for DeepCortex e.g sha-rsa ASDFAEASDF....
ssh_public_key                  = "<SSH_PUBLIC_KEY>"

# the CIDR for a VPN or machine IP(s) that should be able to access DeepCortex e.g. 0.0.0.0/0
access_cidr                     = "<ACCESS_CIDR>"

# the CIDR for the IP of the machine that is running the deployment container e.g. 0.0.0.0/0
deploy_cidr                     = "<DEPLOY_CIDR>"

# specify if MSTAR data and CAD data should be uploaded to the default DeepCortex S3 bucket during build (adds 20-30 min to build time)
upload_datasets                 = "true"

### You may change any of the below names if you choose, otherwise the defaults we be used.

# the name of the S3 buckets used for storing terraform artifacts, storing DeepCortex data, and storing DC/OS data
tf_bucket                       = "falcon-deepcortex-mda-dev-terraform"
dcos_apps_bucket                = "falcon-deepcortex-mda-dev-dcos-apps"
dcos_stack_bucket               = "falcon-deepcortex-mda-dev-dcos-backend"

# the tags that will be applied to the infrastructure (environment, owner, usage)
# environment and owner can only be a combined 17 characters
environment                     = "dev"
tag_owner                       = "deepcortex"
tag_usage                       = "falcon"

# the name of the redshfit cluster
redshift_cluster_name           = "falcon-deepcortex-mda-dev-redshift"


### DO NOT CHANGE ANYTHING BELOW THIS LINE

# version of DC/OS
dcos_version                    = "1.10.2"

# public vs private baile
baile_access                    = "private"

# true or false for downloading latest files (frontend and mstar) from S3 rather than using files in the docker container
download_from_s3                = "false"

# prefix for terraform templates
prefix                          = "exvpc_"

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
captain_asg_min_size               = "1"
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
aries_docker_image_version = "0.0.0-d7d4808443dccd85278492a35614894e6051ae23"
baile_docker_image_version = "v1.0.6"
baile_haproxy_docker_image_version = "v1.0"
cortex_docker_image_version = "0.0.0-7f2913f624a1260cf2ed15852c1857ac0e50bbbf"
logstash_docker_image_version = "latest"
orion_docker_image_version = "0.0.0-1ed179f8beed4f129d6fa105250c8ee3246af718"
job_master_docker_image = "deepcortex/cortex-job-master:0.10.0-3-gcdcbf13-SNAPSHOT"
rmq_docker_image_version = "latest"
um_docker_image_version = "v1.0"
salsa_version = "falcon"
