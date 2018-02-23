### You must fill in the following varibles before executing the deployment.
# Remove the <> symbols before deploying.

# the account ID of the AWS account you will deploy to
account                         = "475276989310"

# the public ssh key for the key you would like to use to access the DC/OS machines used for DeepCortex
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzAIMbSVnZohF71QmHYBwZ8049zJgDlQ7/7V/C05sDBd5gUeSqdloLG22YkuooIh6uWtnUtBCZc2Sqlyqveh+ly0BV2K+euBSb58idzldn7Cz/bvJKHjjxN5qe4uiaskJxT6V187GZ3WwJ7vBNkE5NQ1NRz9oZGv7B1mjy1+eUZIMXovv5vAIvorHeOQsussPlTbxpidHb3Nxt7Nq0DyFAtEq0Bkny5bWZJ33hwHc2u4IZTZWR0GVEXdneas7nSbAhyUA/XSQNN9uJTHJjm75oC9UM7rpgpIGgnUVWTz+syCM1uImxwZATaFXYfL6XjwiJFJwkoY0H8uaT8SX/FpgR"

# the CIDR for a VPN or machine IP that should be able to access DeepCortex
access_cidr                     = "205.251.75.6/32"
deploy_cidr                     = "205.251.75.6/32"

### You may change any of the below names if you choose, otherwise the defaults we be used.

# the name of the S3 buckets used for storing terraform artifacts, storing DeepCortex data, and storing DC/OS data
tf_bucket                       = "falcon-deepcortex-test-terraform"
dcos_apps_bucket                = "falcon-deepcortex-test-dcos-apps"
dcos_stack_bucket               = "falcon-deepcortex-test-dcos-backend"

# the tags that will be applied to the infrastructure (environment, owner, usage)
environment                     = "test"
tag_owner                       = "deepcortex"
tag_usage                       = "falcon"

# the name of the redshfit cluster
redshift_cluster_name           = "falcon-deepcortex-test-redshift"

# specify if Public MSTAR data should be uploaded to DeepCortex S3 Bucket
upload_datasets                 = "true"

### DO NOT CHANGE ANYTHING BELOW THIS LINE

# public vs private baile
baile_access                    = "private"

# Packer
packer_base_ami                 = "ami-6f61e60e"
packer_ssh_user                 = "ec2-user"

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

gpu_slave_asg_desired_capacity  = "1"
gpu_slave_asg_min_size          = "1"
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
baile_docker_image_version = "v1.0.0"
baile_haproxy_docker_image_version = "latest"
cortex_docker_image_version = "0.0.0-7f2913f624a1260cf2ed15852c1857ac0e50bbbf"
logstash_docker_image_version = "latest"
orion_docker_image_version = "0.0.0-77ec7b0ac9a37becf35606e404e09c30324da6cb"
job_master_docker_image = "deepcortex/cortex-job-master:0.9.3-194-ga95f9d9"
rmq_docker_image_version = "latest"
um_docker_image_version = "v1.0"
