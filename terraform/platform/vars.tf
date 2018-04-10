# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "tf_bucket" {}
variable "account" {}
variable "access_cidr" {}
variable "deploy_cidr" {}
variable "baile_access" {}
variable "s3_endpoint" {}
variable "download_ssh_keys" { default = "false" }
variable "ssh_keys_s3_bucket" { default = "" }
variable "main_user" {}
variable "salsa_version" {}

# Bootstrap vars

variable "bootstrap_asg_desired_capacity" {}
variable "bootstrap_asg_min_size" {}
variable "bootstrap_asg_max_size" {}
variable "s3_prefix" {}
variable "cluster_name" {}
variable "dcos_stack_bucket" {}
variable "dcos_apps_bucket" {}
variable "dcos_password" {}

# Master vars

variable "master_asg_desired_capacity" {}
variable "master_asg_min_size" {}
variable "master_asg_max_size" {}

# Slave vars

variable "slave_asg_desired_capacity" {}
variable "slave_asg_min_size" {}
variable "slave_asg_max_size" {}

# GPU slave vars

variable "gpu_slave_asg_desired_capacity" {}
variable "gpu_slave_asg_min_size" {}
variable "gpu_slave_asg_max_size" {}

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

variable "argo_docker_image_version" {}
variable "aries_docker_image_version" {}
variable "baile_docker_image_version" {}
variable "baile_haproxy_docker_image_version" {}
variable "cortex_docker_image_version" {}
variable "logstash_docker_image_version" {}
variable "orion_docker_image_version" {}
variable "job_master_docker_image" {}
variable "pegasus_docker_image_version" {}
variable "rmq_docker_image_version" {}
variable "taurus_docker_image_version" {}
variable "um_docker_image_version" {}
variable "upload_datasets" { default = "false"}
variable "download_from_s3" { default = "true" }
variable "online_prediction" { default = "true" }
variable "only_public" { default = "false" }

locals {
    create_deploy_sgs = "${var.access_cidr == var.deploy_cidr ? 0 : 1}"
    create_public_baile_access = "${var.baile_access == "public" ? 1 : 0}"
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
