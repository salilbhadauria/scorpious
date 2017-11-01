# vim: ts=4:sw=4:et:ft=hcl

module "vpc" {
    source = "../modules/vpc"
    
    vpc_cidr               = "${var.vpc_cidr}"
    azs                    = "${var.azs}"
    public_subnets         = "${var.public_subnets}"
    private_subnets        = "${var.private_subnets}"
    private_subnets_egress = "${var.private_subnets_egress}"

    tags     = "${var.tags}" 
}

module "sg_bastion" {
    source = "../modules/security_group"

    vpc_id = "${module.vpc.vpc_id}"

    sg_name = "ssh-bastion"
    sg_description = "some description"
    
    ingress_rules_cidr = [
        {
            protocol = "tcp"
            from_port = "80"
            to_port = "80"
            cidr_blocks = "10.0.0.1/32, 10.0.0.2/32"
        },
        {
            protocol = "tcp"
            from_port = "81"
            to_port = "81"
            cidr_blocks = "10.0.0.3/32, 10.0.0.4/32"
        },
    ]
    tags = "${var.tags}"
}

