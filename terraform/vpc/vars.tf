# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}

variable "bucket" {}

variable "vpc_cidr" {}
variable "azs" {
    description = "Array AVZs. Must match number of public and or private subnets"
    type    = "list"
}

variable "public_subnets" {
    description = "Array of public subnet CIDR. Must match number of AVZs"
    type        = "list"
}

variable "private_subnets" {
    description = "Array of private subnet CIDR. Must match number of AVZs"
    type    = "list"
}

variable "private_subnets_egress" {
    description = "Array of private egress subnet CIDR. Must match number of AVZs"
    type    = "list"
}

variable "tag_owner" {}
variable "tag_usage" {}

locals {
    tags = {
        owner       = "${var.tag_owner}"
        environment = "${var.environment}"
        layer       = "vpc"
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
            value = "vpc"
            propagate_at_launch = "true"
        },
        {
            key   = "usage"
            value = "${var.tag_usage}"
            propagate_at_launch = "true"
        },
    ]
}

variable "ssh_public_key" {}
variable "bastion_ami_id" {}
variable "nat_ami_id" { default = "ami-15e9c770" }
variable "access_cidr" {}

