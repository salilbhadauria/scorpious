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

resource "aws_s3_bucket" "dcos_stack_bucket" {
  bucket = "deepcortex-dcos-backend"
  acl    = "private"

  tags {
      name = "deepcortex-dcos-backend"
      owner       = "owner"
      environment = "env"
      layer       = "layer"
      usage       = "usage"
  }

  lifecycle {
      prevent_destroy = false
  }
}

#########################################################
# Internal zone
module "dcos_stack_zone" {
    source = "../modules/dns_zone"
    domain = "${var.domain}"
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    tags   = "${var.tags}"
}

#########################################################
# Security Groups

module "dcos_stack_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "docker_stack"
    sg_description = "some description"

    ingress_rules_self = [
        {
            protocol    = "all"
            from_port   = "0"
            to_port     = "0"
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
    tags = "${var.tags}"
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
        {
            protocol    = "all"
            from_port   = "0"
            to_port     = "0"
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

data "template_file" "bootstrap_userdata" {
  template = "${file("../templates/bootstrap_userdata.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${aws_s3_bucket.dcos_stack_bucket.id}"
    s3_prefix = "${var.environment}-${var.s3_prefix}"
    num_masters = "${var.master_asg_desired_capacity}"
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${module.dcos_stack_zone.domain}"
    masters_elb = "${var.environment}-${var.master_elb_dns_name}-internal.${module.dcos_stack_zone.domain}"
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
  dns_records         = [ "${var.environment}-${var.bootstrap_elb_dns_name}" ]
  dns_zone_id         = "${module.dcos_stack_zone.zone_id}"
  tags                = "${var.tags}"
}

module "bootstrap_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "bootstrap*"
    lc_name_prefix          = "${var.environment}-bootstrap-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${data.terraform_remote_state.vpc.devops_key_name}"
    lc_security_groups      = [ "${module.bootstrap_sg.id}", "${module.dcos_stack_sg.id}" ]
    lc_user_data            = "${data.template_file.bootstrap_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-bootstrap-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.bootstrap_asg_desired_capacity}"
    asg_min_size            = "${var.bootstrap_asg_min_size}"
    asg_max_size            = "${var.bootstrap_asg_max_size}"
    asg_load_balancers      = [ "${module.bootstrap_elb.elb_id}" ]

    tags_asg = "${var.tags_asg}"
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
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "5050"
            to_port     = "5050"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "2181"
            to_port     = "2181"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "8080"
            to_port     = "8080"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "8181"
            to_port     = "8181"
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
    tags = "${var.tags}"
}

module "master_elb_internal_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "master-elb-internal"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "5050"
            to_port     = "5050"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "2181"
            to_port     = "2181"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "8080"
            to_port     = "8080"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "8181"
            to_port     = "8181"
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

data "template_file" "master_userdata" {
  template = "${file("../templates/master_userdata.tpl")}"

  vars {
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${module.dcos_stack_zone.domain}"
  }
}

module "master_elb" {
  source              = "../modules/elb_external_masters"
  elb_name            = "master-elb"
  elb_is_internal     = "false"
  elb_security_group  = "${module.master_elb_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.public_subnet_ids}" ]
  health_check_target = "TCP:5050"
  dns_records         = [ "${var.environment}-${var.master_elb_dns_name}" ]
  dns_zone_id         = "${module.dcos_stack_zone.zone_id}"
  tags                = "${var.tags}"
}

module "master_elb_internal" {
  source              = "../modules/elb_internal_masters"
  elb_name            = "master-elb-internal"
  elb_security_group  = "${module.master_elb_internal_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.private_egress_subnet_ids}" ]
  health_check_target = "TCP:5050"
  dns_records         = [ "${var.environment}-${var.master_elb_dns_name}-internal" ]
  dns_zone_id         = "${module.dcos_stack_zone.zone_id}"
  tags                = "${var.tags}"
}

module "master_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "master*"
    lc_name_prefix          = "${var.environment}-master-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${data.terraform_remote_state.vpc.devops_key_name}"
    lc_security_groups      = [ "${module.master_sg.id}", "${module.dcos_stack_sg.id}" ]
    lc_user_data            = "${data.template_file.master_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-master-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.master_asg_desired_capacity}"
    asg_min_size            = "${var.master_asg_min_size}"
    asg_max_size            = "${var.master_asg_max_size}"
    asg_load_balancers      = [ "${module.master_elb.elb_id}", "${module.master_elb_internal.elb_id}" ]

    tags_asg = "${var.tags_asg}"
}

#########################################################
# Slaves
module "slave_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "slave"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
            cidr_blocks = "0.0.0.0/0"
        },
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
    tags = "${var.tags}"
}

data "template_file" "slave_userdata" {
  template = "${file("../templates/private_slave_userdata.tpl")}"

  vars {
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${module.dcos_stack_zone.domain}"
  }
}

module "slave_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "slave*"
    lc_name_prefix          = "${var.environment}-slave-"
    lc_instance_type        = "t2.large"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${data.terraform_remote_state.vpc.devops_key_name}"
    lc_security_groups      = [ "${module.slave_sg.id}", "${module.dcos_stack_sg.id}" ]
    lc_user_data            = "${data.template_file.slave_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-slave-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.slave_asg_desired_capacity}"
    asg_min_size            = "${var.slave_asg_min_size}"
    asg_max_size            = "${var.slave_asg_max_size}"

    tags_asg = "${var.tags_asg}"
}

#########################################################
# Public slaves
module "public_slave_sg" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "public-slave"
    sg_description = "some description"

    ingress_rules_cidr = [
        {
            protocol    = "tcp"
            from_port   = "22"
            to_port     = "22"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "80"
            to_port     = "80"
            cidr_blocks = "0.0.0.0/0"
        },
        {
            protocol    = "tcp"
            from_port   = "443"
            to_port     = "443"
            cidr_blocks = "0.0.0.0/0"
        },
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
    tags = "${var.tags}"
}

data "template_file" "public_slave_userdata" {
  template = "${file("../templates/public_slave_userdata.tpl")}"

  vars {
    bootstrap_dns = "${var.environment}-${var.bootstrap_elb_dns_name}.${module.dcos_stack_zone.domain}"
  }
}

module "public_slave_asg" {
    source = "../modules/autoscaling_group"

    ami_name                = "slave*"
    lc_name_prefix          = "${var.environment}-public-slave-"
    lc_instance_type        = "t2.large"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${data.terraform_remote_state.vpc.devops_key_name}"
    lc_security_groups      = [ "${module.public_slave_sg.id}", "${module.dcos_stack_sg.id}" ]
    lc_user_data            = "${data.template_file.public_slave_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-public-slave-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.public_subnet_ids}"
    asg_desired_capacity    = "${var.public_slave_asg_desired_capacity}"
    asg_min_size            = "${var.public_slave_asg_min_size}"
    asg_max_size            = "${var.public_slave_asg_max_size}"

    tags_asg = "${var.tags_asg}"
}
