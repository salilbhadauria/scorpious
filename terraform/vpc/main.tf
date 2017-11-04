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

    key_name   = "devops"
    public_key = "${var.ssh_public_key}"
}

module "eip_bastion" {
    source = "../modules/eip"
}

module "route_private_egress" {
    source = "../modules/routes"

    route_table_id = "${module.vpc.route_table_private_egress}"  

    routes_count = 1
    routes = [
        {
            dest_cidr = "0.0.0.0/0"
            eni_id    = "${module.eip_bastion.eni_id}"
        },
    ]
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

module "asg_gateway" {
    source = "../modules/autoscaling_group"
    
    ami_name = "amzn-ami-2017*"
    lc_name  = "gw"
    lc_instance_type = "t2.small"
    lc_key_name = "${module.devops_key.name}"
    lc_security_groups = [ "${module.sg_bastion.id}" ]

    asg_name = "gw"
    asg_subnet_ids = "${module.vpc.public_subnet_ids}"
    
    tags_asg = "${var.tags_asg}"
}

