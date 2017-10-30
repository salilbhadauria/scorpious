# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" { default = "us-east-2" }

provider "aws" {
    region = "${var.aws_region}"
}

