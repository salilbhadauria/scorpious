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
    key    = "${var.aws_region}/${var.environment}/vpc/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Retrieve IAM data
data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/iam/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Retrieve Redshift data
data "terraform_remote_state" "redshift" {
  backend = "s3"
  config {
    bucket = "${var.tf_bucket}"
    key    = "${var.aws_region}/${var.environment}/redshift/terraform.tfstate"
    region = "${var.aws_region}"
  }
}

# Buckets

resource "aws_s3_bucket" "dcos_stack_bucket" {
  bucket = "${var.dcos_stack_bucket}"
  acl    = "private"
  tags   = "${merge(local.tags, map("name", "${var.dcos_stack_bucket}"))}"
  lifecycle {
      prevent_destroy = false
  }
}

resource "aws_s3_bucket" "dcos_apps_bucket" {
  bucket = "${var.dcos_apps_bucket}"
  acl    = "private"
  tags   = "${merge(local.tags, map("name", "${var.dcos_apps_bucket}"))}"
  lifecycle {
      prevent_destroy = false
  }
}

#########################################################
# Security Groups

module "dcos_stack_sg" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "dcos-stack"
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
    tags = "${local.tags}"
}

#########################################################
# Bootstrap
module "bootstrap_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

module "bootstrap_elb_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

data "template_file" "bootstrap_userdata" {
  template = "${file("../../terraform/templates/bootstrap_userdata.tpl")}"

  vars {
    environment = "${var.environment}"
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${aws_s3_bucket.dcos_stack_bucket.id}"
    s3_prefix = "${var.environment}-${var.s3_prefix}"
    num_masters = "${var.master_asg_desired_capacity}"
    bootstrap_dns = "${module.bootstrap_elb.elb_dns_name}"
    masters_elb = "${module.master_elb_internal.elb_dns_name}"
    aws_region = "${var.aws_region}"
    dns_ip = "${cidrhost(data.terraform_remote_state.vpc.vpc_cidr, 2)}"
  }

  depends_on = [
    "module.bootstrap_elb",
    "module.master_elb_internal"
  ]
}

resource "aws_iam_instance_profile" "bootstrap_instance_profile" {
  name  = "bootstrap_instance_profile"
  role = "${data.terraform_remote_state.iam.bootstrap_iam_role_name}"
}

module "bootstrap_elb" {
  source              = "../../terraform/modules/elb"
  elb_name            = "bootstrap-elb"
  elb_is_internal     = "true"
  elb_security_group  = "${module.bootstrap_elb_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.private_egress_subnet_ids}" ]
  frontend_port       = "8080"
  frontend_protocol   = "http"
  backend_port        = "8080"
  backend_protocol    = "http"
  health_check_target = "TCP:8080"

  tags                = "${local.tags}"
}

module "bootstrap_asg" {
    source = "../../terraform/modules/autoscaling_group"

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

    tags_asg = "${local.tags_asg}"
}

#########################################################
# Master
module "master_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

module "master_elb_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

module "master_elb_internal_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

data "template_file" "master_userdata" {
  template = "${file("../../terraform/templates/master_userdata.tpl")}"

  vars {
    environment = "${var.environment}"
    bootstrap_dns = "${module.bootstrap_elb.elb_dns_name}"
  }

  depends_on = [
    "module.bootstrap_elb"
  ]
}

module "master_elb" {
  source              = "../../terraform/modules/elb_external_masters"
  elb_name            = "master-elb"
  elb_is_internal     = "false"
  elb_security_group  = "${module.master_elb_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.public_subnet_ids}" ]
  health_check_target = "TCP:5050"

  tags                = "${local.tags}"
}

module "master_elb_internal" {
  source              = "../../terraform/modules/elb_internal_masters"
  elb_name            = "master-elb-internal"
  elb_security_group  = "${module.master_elb_internal_sg.id}"
  subnets             = [ "${data.terraform_remote_state.vpc.private_egress_subnet_ids}" ]
  health_check_target = "TCP:5050"

  tags                = "${local.tags}"
}

module "master_asg" {
    source = "../../terraform/modules/autoscaling_group"

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

    tags_asg = "${local.tags_asg}"
}

#########################################################
# Slaves
module "slave_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

data "template_file" "slave_userdata" {
  template = "${file("../../terraform/templates/private_slave_userdata.tpl")}"

  vars {
    environment = "${var.environment}"
    bootstrap_dns = "${module.bootstrap_elb.elb_dns_name}"
  }

  depends_on = [
    "module.bootstrap_elb"
  ]
}

module "slave_asg" {
    source = "../../terraform/modules/autoscaling_group"

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

    tags_asg = "${local.tags_asg}"
}

#########################################################
# Public slaves
module "public_slave_sg" {
    source = "../../terraform/modules/security_group"

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
    tags = "${local.tags}"
}

data "template_file" "public_slave_userdata" {
  template = "${file("../../terraform/templates/public_slave_userdata.tpl")}"

  vars {
    environment = "${var.environment}"
    bootstrap_dns = "${module.bootstrap_elb.elb_dns_name}"
  }

  depends_on = [
    "module.bootstrap_elb"
  ]
}

module "public_slave_asg" {
    source = "../../terraform/modules/autoscaling_group"

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

    tags_asg = "${local.tags_asg}"
}

#########################################################
# Captain
module "captain_sg" {
    source = "../../terraform/modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "captain"
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

data "template_file" "captain_userdata" {
  template = "${file("../../terraform/templates/captain_userdata.tpl")}"

  vars {
    environment = "${var.environment}"
    dcos_master_url = "${module.master_elb_internal.elb_dns_name}"
    dcos_apps_bucket = "${aws_s3_bucket.dcos_apps_bucket.id}"
    aws_region = "${var.aws_region}"
    redshift_user = "${data.terraform_remote_state.redshift.redshift_master_username}"
    redshift_password = "${data.terraform_remote_state.redshift.redshift_master_password}"
    redshift_host = "${data.terraform_remote_state.redshift.redshift_url}"
  }

  depends_on = [
    "module.master_elb_internal"
  ]
}

module "captain_asg" {
    source = "../../terraform/modules/autoscaling_group"

    ami_name                = "captain*"
    lc_name_prefix          = "${var.environment}-captain-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${data.terraform_remote_state.vpc.devops_key_name}"
    lc_security_groups      = [ "${module.captain_sg.id}", "${module.dcos_stack_sg.id}" ]
    lc_user_data            = "${data.template_file.captain_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrap_instance_profile.id}"

    asg_name                = "${var.environment}-captain-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = "${var.captain_asg_desired_capacity}"
    asg_min_size            = "${var.captain_asg_min_size}"
    asg_max_size            = "${var.captain_asg_max_size}"

    tags_asg = "${local.tags_asg}"
}
