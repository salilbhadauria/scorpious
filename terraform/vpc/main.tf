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
    bucket = "${var.bucket}"
    key    = "${var.aws_region}/${var.environment}/iam/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

#########################################################

module "vpc" {
    source = "../../terraform/modules/vpc"

    vpc_cidr               = "${var.vpc_cidr}"
    azs                    = "${var.azs}"
    public_subnets         = "${var.public_subnets}"
    private_subnets        = "${var.private_subnets}"
    private_egress_subnets = "${var.private_subnets_egress}"

    tags     = "${local.tags}"
}

module "devops_key" {
    source = "../../terraform/modules/key_pair"

    key_name   = "${var.environment}-devops"
    public_key = "${var.ssh_public_key}"
}

module "sg_bastion" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "ssh-bastion"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
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

module "sg_public_subnet" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "public-subnet"
    sg_description = "Public subnets SG"

    ingress_rules_sgid_count = 1
    ingress_rules_sgid = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            sg_id       = "${module.sg_bastion.id}"
            description = "SSH access from bastion"
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

module "sg_private_subnet" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "private-subnet"
    sg_description = "Private subnets SG"

    ingress_rules_sgid_count = 1
    ingress_rules_sgid = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            sg_id       = "${module.sg_bastion.id}"
            description = "SSH access from bastion"
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

module "sg_private_egress_subnet" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "private-egress-subnet"
    sg_description = "Private Egress subnets SG"

    ingress_rules_sgid_count = 1
    ingress_rules_sgid = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            sg_id       = "${module.sg_bastion.id}"
            description = "SSH access from bastion"
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

module "sg_nat" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "nat-instance"
    sg_description = "NAT instances SG"

    ingress_rules_sgid_count = 2
    ingress_rules_sgid = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            sg_id       = "${module.sg_bastion.id}"
            description = "SSH access from bastion"
        },
        {
            protocol    = "all"
            from_port   = "0"
            to_port     = "65536"
            sg_id       = "${module.sg_private_egress_subnet.id}"
            description = "Allow all traffic from Private egress subnet"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "all"
            from_port   = "0"
            to_port     = "65536"
            cidr_blocks = "${join(",", var.private_subnets_egress)}"
            description = "Allow all traffic from Private egress subnet"
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

resource "aws_iam_instance_profile" "nat_instance_profile" {
    name = "nat_instance_profile"
    role = "${data.terraform_remote_state.iam.nat_instance_iam_role_name}"
}

data "template_file" "nat_instance_userdata" {
    template = "${file("../../terraform/templates/nat_instance_userdata.tpl")}"
    vars {
        azs         = "${join(",", var.azs)}"
        rts         = "${join(",", module.vpc.route_tables_private_egress)}"
        egress_cidr = "${join(",", var.private_subnets_egress)}"
        vpc_cidr    = "${var.vpc_cidr}"
    }
}

module "asg_nat" {
    source = "../../terraform/modules/autoscaling_group"

    lc_ami_id          = "${var.nat_ami_id}"
    lc_name_prefix     = "${var.environment}-nat-"
    lc_instance_type   = "t2.small"
    lc_ebs_optimized   = "false"
    lc_key_name        = "${module.devops_key.name}"
    lc_security_groups = [ "${module.sg_nat.id}" ]
    lc_user_data       = "${data.template_file.nat_instance_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.nat_instance_profile.id}"

    asg_name             = "nat-instance-asg"
    asg_subnet_ids       = "${module.vpc.public_subnet_ids}"
    asg_desired_capacity = "${length(var.azs)}"
    asg_min_size         = "${length(var.azs)}"
    asg_max_size         = "${length(var.azs)}"

    tags_asg = "${local.tags_asg}"
    name_tag = "NAT"

}

module "asg_bastion" {
    source = "../../terraform/modules/autoscaling_group"

    lc_ami_id          = "${var.bastion_ami_id}"
    lc_name_prefix     = "${var.environment}-bastion-"
    lc_instance_type   = "t2.small"
    lc_ebs_optimized   = "false"
    lc_key_name        = "${module.devops_key.name}"
    lc_security_groups = [ "${module.sg_bastion.id}" ]

    asg_name             = "bastion-asg"
    asg_subnet_ids       = "${module.vpc.public_subnet_ids}"
    asg_desired_capacity = 1
    asg_min_size         = 1
    asg_max_size         = 1

    tags_asg = "${local.tags_asg}"
    name_tag = "bastion"
}
