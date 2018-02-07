# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "dcos_apps_bucket" {}
variable "online_prediction_bucket" {}
variable "tag_owner" {}
locals {
  arn = "${var.aws_region == "us-gov-west-1" ? "aws-us-gov" : "aws"}"
}
