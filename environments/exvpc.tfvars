### You must fill in the following varibles before executing the deployment.
# Remove the <> symbols before deploying.

# the account ID of the AWS account you will deploy to
account                         = "475276989310"

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

# the ami id for the machine that will serve as the bastion (can be CentOS or Amazon Linux)
bastion_ami_id                  = "ami-128c0873"

# the ami id for the machines that will run DeepCortex (should be a CentOS 7.4 ami)
packer_base_ami                 = "ami-128c0873"

# the default ssh user for the above ami (likely centos for CentOS machines, but could be ec2-user so make sure to check the ami you are using)
packer_ssh_user                 = "centos"

# the VPC ID of the VPC you will launch DeepCortex into
vpc_id                          = "vpc-7a51d11f"

# the VPC S3 Endpoint of the VPC you will launch DeepCortex into
vpce_id                         = "vpce-8f887fe6"

# the VPC CIDR block you will launch DeepCortex into
vpc_cidr                        = "10.0.0.0/16"

# the subnet IDs of the subnets you will launch DeepCortex into
subnet_id_1                     = "subnet-b0380fc7"
subnet_id_2                     = "subnet-131e1976"

# the public ssh key for the key you would like to use to access the DC/OS machines used for DeepCortex
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzAIMbSVnZohF71QmHYBwZ8049zJgDlQ7/7V/C05sDBd5gUeSqdloLG22YkuooIh6uWtnUtBCZc2Sqlyqveh+ly0BV2K+euBSb58idzldn7Cz/bvJKHjjxN5qe4uiaskJxT6V187GZ3WwJ7vBNkE5NQ1NRz9oZGv7B1mjy1+eUZIMXovv5vAIvorHeOQsussPlTbxpidHb3Nxt7Nq0DyFAtEq0Bkny5bWZJ33hwHc2u4IZTZWR0GVEXdneas7nSbAhyUA/XSQNN9uJTHJjm75oC9UM7rpgpIGgnUVWTz+syCM1uImxwZATaFXYfL6XjwiJFJwkoY0H8uaT8SX/FpgR"

# the CIDR for a VPN or machine IP that should be able to access DeepCortex
access_cidr                     = "205.251.70.6/32"

# the CIDR for the IP of the machine that is running the deployment container
deploy_cidr                     = "205.251.70.6/32"

# specify if Public MSTAR data should be uploaded to the default DeepCortex S3 bucket
upload_datasets                 = "true"

### You may change any of the below names if you choose, otherwise the defaults we be used.

# the name of the S3 buckets used for storing terraform artifacts, storing DeepCortex data, and storing DC/OS data
tf_bucket                       = "falcon-deepcortex-staging-terraform"
dcos_apps_bucket                = "falcon-deepcortex-staging-dcos-apps"
dcos_stack_bucket               = "falcon-deepcortex-staging-dcos-backend"

# the tags that will be applied to the infrastructure (environment, owner, usage)
# environment and owner can only be a combined 17 characters
environment                     = "staging"
tag_owner                       = "deepcortex"
tag_usage                       = "falcon"

# the name of the redshfit cluster
redshift_cluster_name           = "falcon-deepcortex-staging-redshift"


### DO NOT CHANGE ANYTHING BELOW THIS LINE

# version of DC/OS
dcos_version                    = "1.10.2"

# public vs private baile
baile_access                    = "private"

# true or false for downloading latest files (frontend and mstar) from S3 rather than using files in the docker container
download_from_s3                = "true"

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
baile_docker_image_version = "v1.0.7"
baile_haproxy_docker_image_version = "v1.0"
cortex_docker_image_version = "0.0.0-7f2913f624a1260cf2ed15852c1857ac0e50bbbf"
logstash_docker_image_version = "latest"
orion_docker_image_version = "0.0.0-e53741dfd2840966a6090af62273b866e43ea175"
job_master_docker_image = "deepcortex/cortex-job-master:0.10.0-5-gefa67ab-SNAPSHOT"
rmq_docker_image_version = "latest"
um_docker_image_version = "v1.0"
salsa_version = "falcon"
