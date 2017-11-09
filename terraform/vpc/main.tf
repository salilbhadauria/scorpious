# vim: ts=4:sw=4:et:ft=hcl

module "vpc" {
    source = "../modules/vpc"

    vpc_cidr               = "${var.vpc_cidr}"
    azs                    = "${var.azs}"
    public_subnets         = "${var.public_subnets}"
    private_subnets        = "${var.private_subnets}"
    private_egress_subnets = "${var.private_subnets_egress}"
    nat_gateway            = "true"

    tags     = "${var.tags}"
}

module "devops_key" {
    source = "../modules/key_pair"

    key_name   = "${var.environment}-devops"
    public_key = "${var.ssh_public_key}"
}

module "sg_bastion" {
    source = "../modules/security_group"

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
    tags = "${var.tags}"
}

module "sg_public_subnet" {
    source = "../modules/security_group"

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
    tags = "${var.tags}"
}

module "sg_private_subnet" {
    source = "../modules/security_group"

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
    tags = "${var.tags}"
}

module "sg_private_egress_subnet" {
    source = "../modules/security_group"

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
    tags = "${var.tags}"
}

module "asg_bastion" {
    source = "../modules/autoscaling_group"

    #ami_name           = "amzn-ami-2017*"
    lc_ami_id          = "ami-c5062ba0"
    lc_name_prefix     = "bastion-"
    lc_instance_type   = "t2.small"
    lc_ebs_optimized   = "false"
    lc_key_name        = "${module.devops_key.name}"
    lc_security_groups = [ "${module.sg_bastion.id}" ]

    asg_name             = "bastion-asg"
    asg_subnet_ids       = "${module.vpc.public_subnet_ids}"
    asg_desired_capacity = 1
    asg_min_size         = 1
    asg_max_size         = 1

    tags_asg = "${var.tags_asg}"
}
