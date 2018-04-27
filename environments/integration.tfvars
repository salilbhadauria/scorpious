# Packer
packer_base_ami                 = "ami-0d7c5868"
main_user                 = "ec2-user"

# Ansible
dcos_apps_bucket                = "deepcortex-dcos-apps"

# Terraform
# VPC
tf_bucket                       = "deepcortex-terraform-state"
aws_region                      = "us-east-2"
environment                     = "integration"
account                         = "068078214683"
vpc_cidr                        = "10.0.0.0/16"
azs                             = [ "2a", "2b", "2c", ]
public_subnets                  = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", ]
private_subnets                 = [ "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", ]
private_subnets_egress          = [ "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24", ]
bastion_ami_id                  = "ami-c5062ba0"
nat_ami_id                      = "ami-15e9c770"
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCztxYxgAYrXzSrfu2SDM58Ahca801YVhQ14HCDCRRzeziz6R/zVZATnfrCCUU5N3Fas7foZuzjXfwalD1xRbCABDaQayTSOHEJqsqnjJ2DZadRZJRKsHoEDoXf92963KHPz8BnNmPMTqhc+u115Q4HW3LyHlcIphuHtNcnKnbb4GVfSpOXYUw8b/Z31ujgKMUcyJpITQDDUrjti5+sWdmHOkcaSHS0IZMrLhaw43uCwwXlNxUacKORweTSUhna6HtehnTbgIWnVVJ9KekmV0TffNLbyXrYPluvqVUjs+WkOywvVPyMWxzXmqUU3caD6bXuhyjU8VuKGqXfhu/otvyr"
tag_owner                       = "n911"
tag_usage                       = "test"
access_cidr                     = "0.0.0.0/0"
deploy_cidr                     = "0.0.0.0/0"
baile_access                    = "public"
s3_endpoint                     = "s3.amazonaws.com"

# Platform
dcos_stack_bucket               = "deepcortex-dcos-backend"
private_domain                  = "private.devops.deepcortex.ai"
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
redshift_cluster_name = "redshift-clstr"
redshift_database_name = "redshift_db"
redshift_master_username = "redshift_user"
redshift_node_type = "dc2.large"
redshift_cluster_type = "multi-node"
redshift_number_of_nodes = 2
redshift_encrypted = false
redshift_skip_final_snapshot = true

# Application Docker Image Versions
aries_docker_image_version = "0.0.0-ef21aeb1bd0eb01dca146d29c101994541cc3d81"
baile_docker_image_version = "testv6"
baile_haproxy_docker_image_version = "latest"
cortex_docker_image_version = "0.0.0-f0f882e6cb2d80621f57766c12dfc7a4321bf258"
logstash_docker_image_version = "latest"
orion_docker_image_version = "0.0.0-c12e95e9784037e5ab452183c5bf900ab61cf6dd"
job_master_docker_image = "deepcortex/cortex-job-master:0.9.3-4-g3a424df"
rmq_docker_image_version = "latest"
um_docker_image_version = "v1.0"