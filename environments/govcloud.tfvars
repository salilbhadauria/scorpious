# Packer
packer_base_ami                 = "ami-6f61e60e"
packer_ssh_user                 = "ec2-user"

# Terraform
# VPC
bucket                          = "deepcortex-gov-terraform"
aws_region                      = "us-gov-west-1"
environment                     = "govcloud"
account                         = "475276989310"
vpc_cidr                        = "10.0.0.0/16"
azs                             = [ "1a", "1b" ]
public_subnets                  = [ "10.0.1.0/24", "10.0.2.0/24" ]
private_subnets                 = [ "10.0.11.0/24", "10.0.12.0/24" ]
private_subnets_egress          = [ "10.0.21.0/24", "10.0.22.0/24" ]
bastion_ami_id                  = "ami-b2d056d3"
nat_ami_id                      = "ami-fe991b9f"
ssh_public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzAIMbSVnZohF71QmHYBwZ8049zJgDlQ7/7V/C05sDBd5gUeSqdloLG22YkuooIh6uWtnUtBCZc2Sqlyqveh+ly0BV2K+euBSb58idzldn7Cz/bvJKHjjxN5qe4uiaskJxT6V187GZ3WwJ7vBNkE5NQ1NRz9oZGv7B1mjy1+eUZIMXovv5vAIvorHeOQsussPlTbxpidHb3Nxt7Nq0DyFAtEq0Bkny5bWZJ33hwHc2u4IZTZWR0GVEXdneas7nSbAhyUA/XSQNN9uJTHJjm75oC9UM7rpgpIGgnUVWTz+syCM1uImxwZATaFXYfL6XjwiJFJwkoY0H8uaT8SX/FpgR"
tag_owner                       = "govcloud"
tag_usage                       = "test"
access_cidr                     = "205.251.75.6/32"

# Platform
private_domain                  = "private.devops.deepcortex.ai"
bootstrap_asg_desired_capacity  = "1"
bootstrap_asg_min_size          = "1"
bootstrap_asg_max_size          = "1"
bootstrap_elb_dns_name          = "bootstrap"
s3_prefix                       = "deepcortex-auto"
cluster_name                    = "deepcortex-auto"

master_asg_desired_capacity     = "1"
master_asg_min_size             = "1"
master_asg_max_size             = "1"
master_elb_dns_name             = "master"

slave_asg_desired_capacity     = "3"
slave_asg_min_size             = "1"
slave_asg_max_size             = "3"

public_slave_asg_desired_capacity  = "1"
public_slave_asg_min_size          = "1"
public_slave_asg_max_size          = "1"

# Redshift
redshift_family = "redshift-1.0"
redshift_cluster_name = "deepcortex-redshift"
redshift_database_name = "dev"
redshift_master_username = "deepcortex"
redshift_node_type = "dc1.large"
redshift_cluster_type = "multi-node"
redshift_number_of_nodes = 2
redshift_encrypted = false
redshift_skip_final_snapshot = true
