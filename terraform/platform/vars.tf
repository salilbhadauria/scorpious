# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "tf_bucket" {}
variable "account" {}
variable "access_cidr" {}
variable "deploy_cidr" {}
variable "baile_access" {}

# Bootstrap vars

variable "bootstrap_asg_desired_capacity" {}
variable "bootstrap_asg_min_size" {}
variable "bootstrap_asg_max_size" {}
variable "bootstrap_elb_dns_name" {}
variable "s3_prefix" {}
variable "cluster_name" {}
variable "dcos_stack_bucket" {}
variable "dcos_apps_bucket" {}
variable "dcos_password" {}

# Master vars

variable "master_asg_desired_capacity" {}
variable "master_asg_min_size" {}
variable "master_asg_max_size" {}
variable "master_elb_dns_name" {}

# Slave vars

variable "slave_asg_desired_capacity" {}
variable "slave_asg_min_size" {}
variable "slave_asg_max_size" {}

# Public slave vars

variable "public_slave_asg_desired_capacity" {}
variable "public_slave_asg_min_size" {}
variable "public_slave_asg_max_size" {}

# Captain vars

variable "captain_asg_desired_capacity" {}
variable "captain_asg_min_size" {}
variable "captain_asg_max_size" {}

variable "tag_owner" {}
variable "tag_usage" {}

variable "aries_docker_image_version" {}
variable "baile_docker_image_version" {}
variable "baile_nginx_docker_image_version" {}
variable "cortex_docker_image_version" {}
variable "logstash_docker_image_version" {}
variable "orion_docker_image_version" {}
variable "job_master_docker_image" {}
variable "rmq_docker_image_version" {}
variable "um_docker_image_version" {}
variable "upload_mstar_data" { default = "false"}

locals {
    create_deploy_sgs = "${var.access_cidr == var.deploy_cidr ? 0 : 1}"
    tags = {
        owner       = "${var.tag_owner}"
        environment = "${var.environment}"
        layer       = "platform"
        usage       = "${var.tag_usage}"
    }
    tags_asg = [
        {
            key   = "owner"
            value = "${var.tag_owner}"
            propagate_at_launch = "true"
        },
        {
            key   = "environment"
            value = "${var.environment}"
            propagate_at_launch = "true"
        },
        {
            key   = "layer"
            value = "platform"
            propagate_at_launch = "true"
        },
        {
            key   = "usage"
            value = "${var.tag_usage}"
            propagate_at_launch = "true"
        },
    ]
}
