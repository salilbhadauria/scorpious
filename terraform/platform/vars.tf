# vim: ts=4:sw=4:et:ft=hcl

variable "environment" {
  default = "prd"
}

variable "domain" {
  default = "private.devops.deepcortex.ai"
}

# Bootstrap vars

variable "bootstrap_asg_desired_capacity" {
  default = "1"
}
variable "bootstrap_asg_min_size" {
  default = "1"
}
variable "bootstrap_asg_max_size" {
  default = "1"
}

variable "bootstrap_elb_dns_name" {
  default = "bootstrap"
}

variable "s3_prefix" {
  default = "deepcortex"
}

variable "cluster_name" {
  default = "deepcortex"
}

# Master vars

variable "master_asg_desired_capacity" {
  default = "3"
}
variable "master_asg_min_size" {
  default = "1"
}
variable "master_asg_max_size" {
  default = "3"
}

variable "master_elb_dns_name" {
  default = "master"
}

# tags

# Slave vars

variable "slave_asg_desired_capacity" {
  default = "3"
}
variable "slave_asg_min_size" {
  default = "1"
}
variable "slave_asg_max_size" {
  default = "3"
}

# Public slave vars

variable "public_slave_asg_desired_capacity" {
  default = "3"
}
variable "public_slave_asg_min_size" {
  default = "1"
}
variable "public_slave_asg_max_size" {
  default = "3"
}

variable "tags" {
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

variable "tags_asg" {
    description = "Tag Environment"
    default = [
        {
            key   = "owner"
            value = "owner"
            propagate_at_launch = "true"
        },
        {
            key   = "environment"
            value = "env"
            propagate_at_launch = "true"
        },
        {
            key   = "layer"
            value = "layer"
            propagate_at_launch = "true"
        },
        {
            key   = "usage"
            value = "usage"
            propagate_at_launch = "true"
        }
    ]
}
