# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "online_prediction_bucket" {}
variable "tag_owner" {}
variable "tag_usage" {}
variable "arn" {}

locals {
    tags = {
        owner       = "${var.tag_owner}"
        environment = "${var.environment}"
        layer       = "online-prediction"
        usage       = "${var.tag_usage}"
    }
}
