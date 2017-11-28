# vim:ts=4:sw=4:et:ft=hcl

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
    key    = "${var.aws_region}/${var.environment}/vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}
#########################################################
# Creates a Redshift Cluster
module "redshift-clstr-sg" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "redshift-sg"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "5439"
            to_port     = "5439"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    egress_rules_cidr = [
        {
            protocol    = "all"
            from_port   = "0"
            to_port     = "0"
            cidr_blocks = "0.0.0.0/0"
        },
    ]
    tags = "${local.tags}"
}

resource "aws_redshift_parameter_group" "redshift-clstr-pg" {
  name   = "redshift-parameter-group"
  family = "${var.redshift_family}"
}

resource "aws_redshift_subnet_group" "redshift-subnet-grp" {
  name       = "redshift-subnet-group"
  subnet_ids = [ "${data.terraform_remote_state.vpc.public_subnet_ids}" ]

  tags = "${local.tags}"
}

resource "random_string" "redshift_password" {
  length = 19
  special = false
}

resource "aws_redshift_cluster" "redshift-clstr" {
  cluster_identifier           = "redshift-clstr"
  database_name                = "${var.redshift_database_name}"
  master_username              = "${var.redshift_master_username}"
  master_password              = "${random_string.redshift_password.result}"
  node_type                    = "${var.redshift_node_type}"
  cluster_type                 = "${var.redshift_cluster_type}"
  number_of_nodes              = "${var.redshift_number_of_nodes}"
  encrypted                    = "${var.redshift_encrypted}"
  skip_final_snapshot          = "${var.redshift_skip_final_snapshot}"
  vpc_security_group_ids       = ["${module.redshift-clstr-sg.id}"]
  cluster_subnet_group_name    = "${aws_redshift_subnet_group.redshift-subnet-grp.id}"
  final_snapshot_identifier    = "final-redshift-snapshot"
  cluster_parameter_group_name = "${aws_redshift_parameter_group.redshift-clstr-pg.id}"

  tags = "${local.tags}"
}
