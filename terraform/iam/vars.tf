# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "tf_bucket" {}
variable "dcos_apps_bucket" {}
variable "tag_owner" {}
variable "arn" { default = "aws"}
variable "only_public" { default = "false" }
variable "ssh_keys_s3_bucket" {}
variable "download_ssh_keys" { default = "false" }
variable "create_iam" { default = "true" }
variable "artifacts_s3_bucket" { default = "" }

locals {
    create_nat = "${var.only_public == "true" ? 0 : 1}"
    create_iam = "${var.create_iam == "true" ? 1 : 0}"
    create_extra_ssh_key_policy = "${var.download_ssh_keys == "true" ? 1 : 0}"
    create_artifacts_bucket_policy = "${var.artifacts_s3_bucket != "" ? 1 : 0}"
}