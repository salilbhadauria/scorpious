# vim: ts=4:sw=4:et:ft=hcl

variable "tags" {
    description = "Tag Environment"
    default = {
        owner       = "owner"
        environment = "env"
        layer       = "layer"
        usage       = "usage"
    }
}

