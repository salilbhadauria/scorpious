# vim: ts=4:sw=4:et:ft=hcl

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "devops_key_name" {
  value = "${module.devops_key.name}"
}

output "sg_bastion_id" {
  value = "${module.sg_bastion.id}"
}

output "asg_bastion_name" {
  value = "${module.asg_bastion.asg_name}"
}
