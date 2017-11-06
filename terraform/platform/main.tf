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

module "devops_key" {
    source = "../modules/key_pair"

    key_name   = "platform"
    public_key = "${var.ssh_public_key}"
}

module "sg_bootstrap" {
    source = "../modules/security_group"

    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

    sg_name = "ssh-bootstrap"
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
    tags = "${var.bootstrap_sg_tags}"
}

data "template_file" "bootstrap_userdata" {
  template = "${file("../templates/bootstrap_userdata.tpl")}"
}

resource "aws_iam_instance_profile" "bootstrapp_instance_profile" {
  name  = "bootstrapp_instance_profile"
  role = "${data.terraform_remote_state.iam.bootstrap_iam_role_name}"
}

module "bootstrap" {
    source = "../modules/autoscaling_group"

    ami_name                = "bootstrap*"
    lc_name_prefix          = "bootstrap-"
    lc_instance_type        = "t2.medium"
    lc_ebs_optimized        = "false"
    lc_key_name             = "${module.devops_key.name}"
    lc_security_groups      = [ "${module.sg_bootstrap.id}" ]
    lc_user_data            = "${data.template_file.bootstrap_userdata.rendered}"
    lc_iam_instance_profile = "${aws_iam_instance_profile.bootstrapp_instance_profile.id}"

    asg_name                = "bootstrap-asg"
    asg_subnet_ids          = "${data.terraform_remote_state.vpc.private_egress_subnet_ids}"
    asg_desired_capacity    = 1
    asg_min_size            = 1
    asg_max_size            = 1

    tags_asg = "${var.bootstrap_asg_tags}"
}
