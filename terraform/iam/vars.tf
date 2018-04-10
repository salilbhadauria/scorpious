# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "dcos_apps_bucket" {}
variable "tag_owner" {}
variable "arn" { default = "aws"}
variable "only_public" { default = "false" }

locals {
    create_nat = "${var.only_public == "true" ? 0 : 1}"
}