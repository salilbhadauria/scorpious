# vim: ts=4:sw=4:et:ft=hcl

variable "aws_region" {}
variable "environment" {}
variable "dcos_apps_bucket" {}
locals {
  arn = "${var.aws_region == "us-gov-west-1" ? "arn:aws-us-gov:s3" : "arn:aws:s3"}"
}