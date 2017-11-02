# vim: ts=4:sw=4:et:ft=hcl

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "azs" {
    description = "Array AVZs. Must match number of public and or private subnets"
    type    = "list"
    default = [
        "1a",
        "1b",
        "1c",
        "1d",
        "1e",
    ]
}

variable "public_subnets" {
    description = "Array of public subnet CIDR. Must match number of AVZs"
    type        = "list"
    default     = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24",
        "10.0.5.0/24"
    ]
}

variable "private_subnets" {
    description = "Array of private subnet CIDR. Must match number of AVZs"
    type    = "list"
    default = [
        "10.0.11.0/24",
        "10.0.12.0/24",
        "10.0.13.0/24",
        "10.0.14.0/24",
        "10.0.15.0/24"
    ]
}

variable "private_subnets_egress" {
    description = "Array of private egress subnet CIDR. Must match number of AVZs"
    type    = "list"
    default = [
        "10.0.21.0/24",
        "10.0.22.0/24",
        "10.0.23.0/24",
        "10.0.24.0/24",
        "10.0.25.0/24"
    ]
}

variable "tags" {
    description = "Tag Environment"
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
        },
    ]
}
