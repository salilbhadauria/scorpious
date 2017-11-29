# Packer
packer_base_ami                 = ""
packer_ssh_user                 = "ec2-user"

# Terraform
# VPC
bucket                          = "deepcortex-terraform-state"
aws_region                      = ""
environment                     = "develop"
account                         = ""
vpc_cidr                        = "10.0.0.0/16"
azs                             = [ "2a", "2b", "2c", ]
public_subnets                  = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", ]
private_subnets                 = [ "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", ]
private_subnets_egress          = [ "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24", ]
bastion_ami_id                  = ""
ssh_public_key                  = ""
tag_owner                       = "owner"
tag_usage                       = "usage"
access_cidr                     = "0.0.0.0/0"

# Platform
private_domain                  = "private.devops.deepcortex.ai"
bootstrap_asg_desired_capacity  = "1"
bootstrap_asg_min_size          = "1"
bootstrap_asg_max_size          = "1"
bootstrap_elb_dns_name          = "bootstrap"
s3_prefix                       = "deepcortex"
cluster_name                    = "deepcortex"

master_asg_desired_capacity     = "3"
master_asg_min_size             = "1"
master_asg_max_size             = "3"
master_elb_dns_name             = "master"

slave_asg_desired_capacity     = "3"
slave_asg_min_size             = "1"
slave_asg_max_size             = "3"

public_slave_asg_desired_capacity  = "3"
public_slave_asg_min_size          = "1"
public_slave_asg_max_size          = "3"

# Redshift
redshift_family = "redshift-1.0"
redshift_database_name = "redshift_db"
redshift_master_username = "redshift_user"
redshift_node_type = "dc2.large"
redshift_cluster_type = "multi-node"
redshift_number_of_nodes = 2
redshift_encrypted = false
redshift_skip_final_snapshot = true
