# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

# Retrieve VPC data
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Buckets

resource "aws_s3_bucket" "dcos_stack_bucket" {
  bucket = "${var.dcos_stack_bucket}"
  acl    = "private"
  tags   = "${merge(local.tags, map("name", "${var.dcos_stack_bucket}"))}"
  lifecycle {
      prevent_destroy = false
  }
}

resource "aws_s3_bucket" "dcos_apps_bucket" {
  bucket = "${var.dcos_apps_bucket}"
  acl    = "private"
  tags   = "${merge(local.tags, map("name", "${var.dcos_apps_bucket}"))}"
  lifecycle {
      prevent_destroy = false
  }
}

data "template_file" "dcos_apps_bucket_policy" {
  template = "${file("../../terraform/templates/dcos_apps_bucket_policy_${var.baile_access}.tpl")}"

  vars {
    dcos_apps_bucket_arn = "${aws_s3_bucket.dcos_apps_bucket.arn}"
    access_cidr = "${var.access_cidr}"
    deploy_cidr = "${var.deploy_cidr}"
    vpce_id = "${data.terraform_remote_state.vpc.vpce_id}"
  }

  depends_on = [
    "aws_s3_bucket.dcos_apps_bucket"
  ]
}

resource "aws_s3_bucket_policy" "dcos_apps_bucket_policy" {
  bucket = "${aws_s3_bucket.dcos_apps_bucket.id}"
  policy = "${data.template_file.dcos_apps_bucket_policy.rendered}"

  depends_on = [
    "aws_s3_bucket.dcos_apps_bucket"
  ]
}

