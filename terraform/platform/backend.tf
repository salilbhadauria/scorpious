# vim:ts=4:sw=4:et:ft=hcl

terraform {

    required_version = ">= 0.10.7"

    backend "s3" {
        bucket = "dcos-cortex-infrastructure-n911"
        key    = "platform/terraform.tfstate"
        region = "us-east-2"
    }
}
