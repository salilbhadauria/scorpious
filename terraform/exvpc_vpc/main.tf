# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# Retrieve IAM data

data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/c2s_iam/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

#########################################################

module "devops_key" {
    source = "../../terraform/modules/key_pair"

    key_name   = "${var.tag_owner}-${var.environment}"
    public_key = "${var.ssh_public_key}"
}

module "sg_bastion" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${var.vpc_id}"

    sg_name = "ssh-bastion-${var.tag_owner}-${var.environment}"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            cidr_blocks = "${var.access_cidr}"
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

resource "aws_iam_instance_profile" "bastion_profile" {
    name = "${var.tag_owner}-${var.environment}-bastion_profile"
    role = "${data.terraform_remote_state.iam.bastion_iam_role_name}"
}

module "asg_bastion" {
    source = "../../terraform/modules/autoscaling_group"

    lc_ami_id          = "${var.bastion_ami_id}"
    lc_name_prefix     = "${var.environment}-bastion-"
    lc_instance_type   = "t2.small"
    lc_ebs_optimized   = "false"
    lc_key_name        = "${module.devops_key.name}"
    lc_security_groups = [ "${module.sg_bastion.id}" ]
    lc_user_data       = "#!/bin/bash\ncurl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm && yum install -y amazon-ssm-agent.rpm"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bastion_profile.id}"

    asg_name             = "${var.tag_owner}-${var.environment}-bastion-asg"
    asg_subnet_ids       = [ "${var.subnet_id_1}","${var.subnet_id_2}" ]
    asg_desired_capacity = 1
    asg_min_size         = 1
    asg_max_size         = 1

    tags_asg = "${local.tags_asg}"
    asg_name_tag = "${var.tag_owner}-${var.environment}-bastion-asg"
    instance_name_tag = "${var.tag_owner}-${var.environment}-bastion"
    instance_role_tag = "bastion"
}
