# vim: ts=4:sw=4:et:ft=hcl

variable "environment" {
  default = "prd"
}

variable "ssh_public_key" {
    default = <<SPK
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEUank0MqgF6h0lyixJ7kBtQSblFXCo8SIHK8+OvThmUAQHYED4f9KXCj+6IdBR3mJxnkZ3mgQHkQdXfhrGfpDi3EryDkeon3t8bACvpe9AmKpxx2oZPinmG+r7th6sZeQiwBLJAmJkKtEXsQE+gvSPkXEEQEK3/90rrF0d7QbF0F88pIM3B4iPb5ppq+NqISlJkgynlKt28MWBYj3Z6PFiYUcDe6zKS8kq+kfJOIav6o7xHwZUm5EWWdCs5zMfcFAoPrb1tdsr3ft/fML+lXMHrfY+wv+W7g2ByhX4UmPLOjPhit/yhGweP3M7mIPpYN9iqnFaLbUmW+8t81CXSxj
SPK
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

variable "bootstrap_dns_name" {
  default = "bootstrap.dcos_stack.com"
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
        },
        {
            key   = "name"
            value = "master"
            propagate_at_launch = "true"
        }
    ]
}


