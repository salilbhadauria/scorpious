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

