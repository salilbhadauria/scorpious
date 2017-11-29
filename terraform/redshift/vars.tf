# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "tf_bucket" {}
variable "account" {}

# Redshift vars
variable "environment" {}

variable "tag_owner" {}
variable "tag_usage" {}

locals {
    tags = {
        owner       = "${var.tag_owner}"
        environment = "${var.environment}"
        layer       = "dns"
        usage       = "${var.tag_usage}"
    }
}

variable "redshift_family" {}
variable "redshift_database_name" {}
variable "redshift_master_username" {}
variable "redshift_node_type" {}
variable "redshift_cluster_type" {}
variable "redshift_number_of_nodes" {}
variable "redshift_encrypted" {}
variable "redshift_skip_final_snapshot" {}
