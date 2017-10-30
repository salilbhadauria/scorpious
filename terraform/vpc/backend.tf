# vim:ts=4:sw=4:et:ft=hcl

terraform {

    required_version = ">= 0.10.8"

    #backend "s3" {
    #    bucket = "${var.backend_bucket}"
    #    key    = "${var.backend_bucket_prefix}"
    #    region = "${var.backend_bucket_region}"
    #}

    backend "local" {
        path = ".backend/terraform.tfstate"
    }
}

