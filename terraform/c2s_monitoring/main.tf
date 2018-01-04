# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# Retrieve VPC data
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/c2s_vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Retrieve IAM data
data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/c2s_iam/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Retrieve Redshift data
data "terraform_remote_state" "redshift" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/c2s_redshift/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Retrieve Platform data
data "terraform_remote_state" "platform" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/c2s_platform/terraform.tfstate"
    region = "${var.aws_region}"
  }
}