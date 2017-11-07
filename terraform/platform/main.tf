# vim: ts=4:sw=4:et:ft=hcl

#########################################################
# Retrieve VPC data
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "dcos-cortex-infrastructure-n911"
    key    = "vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

# Retrieve IAM data
data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "dcos-cortex-infrastructure-n911"
    key    = "iam/terraform.tfstate"
    region = "us-east-2"
  }
}

#########################################################
# Create ssh key
module "devops_key" {
    source = "../modules/key_pair"

    key_name   = "platform"
    public_key = "${var.ssh_public_key}"
}

#########################################################
# Create a private zone
module "zone_private_devops_deepcortex_ai" {
    source = "../modules/dns_zone"
    domain = "${var.domain}"
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    tags   = "${var.zone_private_devops_deepcortex_ai_tags}"
}

#########################################################
# Bootstrap
module "bootstrap_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "bootstrap"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "8080"
            to_port     = "8080"
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
    tags = "${var.bootstrap_sg_tags}"
}

module "bootstrap_elb_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "bootstrap-elb"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "8080"
            to_port     = "8080"
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
    tags = "${var.bootstrap_elb_sg_tags}"
}

data "template_file" "bootstrap_userdata" {
  template = "${file("../templates/bootstrap_userdata.tpl")}"

  vars {
    num_masters = "${var.master_asg_desired_capacity}"
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${var.domain}"
    masters_elb = "${var.environment}-${var.master_elb_dns_name}.${var.domain}"
    aws_region = "${var.aws_region}"
  }
}

resource "aws_iam_instance_profile" "bootstrap_instance_profile" {
  name  = "bootstrap_instance_profile"
  role = "${data.terraform_remote_state.iam.bootstrap_iam_role_name}"
}

module "bootstrap_elb" {
  source              = "../modules/elb"
  elb_name            = "bootstrap-elb"
  elb_is_internal     = "true"
  elb_security_group  = "${module.bootstrap_elb_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.private_egress_subnet_ids}" ]
  frontend_port       = "8080"
  frontend_protocol   = "http"
  backend_port        = "8080"
  backend_protocol    = "http"
  health_check_target = "TCP:8080"
  environment         = "${var.environment}"

  dns_zone_id = "${module.zone_private_devops_deepcortex_ai.zone_id}"
  dns_records = [ "${var.environment}-${var.bootstrap_elb_dns_name}.${var.domain}" ]
}

module "bootstrap_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "bootstrap*"
    lc_name_prefix          = "${var.environment}-bootstrap-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${module.devops_key.name}"
    lc_security_groups      = [ "${module.bootstrap_sg.id}" ]
    lc_user_data            = "${data.template_file.bootstrap_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-bootstrap-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.bootstrap_asg_desired_capacity}"
    asg_min_size            = "${var.bootstrap_asg_min_size}"
    asg_max_size            = "${var.bootstrap_asg_max_size}"
    asg_load_balancers      = [ "${module.bootstrap_elb.elb_id}" ]

    tags_asg = "${var.bootstrap_asg_tags}"
}

#########################################################
# Master
module "master_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "master"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "5050"
            to_port     = "5050"
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
    tags = "${var.master_sg_tags}"
}

module "master_elb_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "master-elb"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
    ]

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
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
    tags = "${var.master_elb_sg_tags}"
}

data "template_file" "master_userdata" {
  template = "${file("../templates/master_userdata.tpl")}"

  vars {
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${var.domain}"
  }
}

module "master_elb" {
  source              = "../modules/elb"
  elb_name            = "master-elb"
  elb_is_internal     = "true"
  elb_security_group  = "${module.master_elb_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.private_egress_subnet_ids}" ]
  frontend_port       = "80"
  frontend_protocol   = "http"
  backend_port        = "80"
  backend_protocol    = "http"
  health_check_target = "TCP:5050"
  environment         = "${var.environment}"

  dns_zone_id = "${module.zone_private_devops_deepcortex_ai.zone_id}"
  dns_records = [ "${var.environment}-${var.master_elb_dns_name}.${var.domain}" ]
}

module "master_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "master*"
    lc_name_prefix          = "${var.environment}-master-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${module.devops_key.name}"
    lc_security_groups      = [ "${module.master_sg.id}" ]
    lc_user_data            = "${data.template_file.master_userdata.rendered}"

    asg_name                = "${var.environment}-master-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.master_asg_desired_capacity}"
    asg_min_size            = "${var.master_asg_min_size}"
    asg_max_size            = "${var.master_asg_max_size}"
    asg_load_balancers      = [ "${module.master_elb.elb_id}" ]

    tags_asg = "${var.master_asg_tags}"
}
