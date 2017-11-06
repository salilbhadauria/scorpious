# vim: ts=4:sw=4:et:ft=hcl

# Redshift vars
variable "environment" {
  default = "prd"
}

variable "redshift_sg_tags" {
    description = "Tag Environment"
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

variable "redshift_subnet_group_tags" {
    description = "Tag Environment"
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

variable "redshift_clstr_tags" {
    description = "Tag Environment"
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

variable "redshift_family" {
  default = "redshift-1.0"
}
variable "redshift_database_name" {
  default = "redshift_db"
}
variable "redshift_master_username" {
  default = "redshift_user"
}
variable "redshift_node_type" {
  default = "dc2.large"
}
variable "redshift_cluster_type" {
  default = "multi-node"
}
variable "redshift_number_of_nodes" {
  default = 2
}
variable "redshift_encrypted" {
  default = false
}
variable "redshift_skip_final_snapshot" {
  default = true
}
