# vim: ts=4:sw=4:et:ft=hcl

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "public_subnet_ids" {
  value = [ "${module.vpc.public_subnet_ids}" ]
}

output "private_subnet_ids" {
  value = [ "${module.vpc.private_subnet_ids}" ]
}

output "private_egress_subnet_ids" {
  value = [ "${module.vpc.private_egress_subnet_ids}" ]
}

output "devops_key_name" {
  value = "${module.devops_key.name}"
}

output "sg_private_egress_subnet_id" {
  value = "${module.sg_private_egress_subnet.id}"
}
output "sg_bastion_id" {
  value = "${module.sg_bastion.id}"
}
