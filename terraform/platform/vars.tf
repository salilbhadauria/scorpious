# vim: ts=4:sw=4:et:ft=hcl

variable "ssh_public_key" {
    default = <<SPK
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEUank0MqgF6h0lyixJ7kBtQSblFXCo8SIHK8+OvThmUAQHYED4f9KXCj+6IdBR3mJxnkZ3mgQHkQdXfhrGfpDi3EryDkeon3t8bACvpe9AmKpxx2oZPinmG+r7th6sZeQiwBLJAmJkKtEXsQE+gvSPkXEEQEK3/90rrF0d7QbF0F88pIM3B4iPb5ppq+NqISlJkgynlKt28MWBYj3Z6PFiYUcDe6zKS8kq+kfJOIav6o7xHwZUm5EWWdCs5zMfcFAoPrb1tdsr3ft/fML+lXMHrfY+wv+W7g2ByhX4UmPLOjPhit/yhGweP3M7mIPpYN9iqnFaLbUmW+8t81CXSxj
SPK
}

variable "bootstrap_sg_tags" {
    description = "Tag Environment"
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

variable "bootstrap_asg_tags" {
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
            value = "bootstrap"
            propagate_at_launch = "true"
        }
    ]
}
