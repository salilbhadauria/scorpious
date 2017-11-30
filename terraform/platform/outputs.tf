# vim: ts=4:sw=4:et:ft=hcl

output "master_elb_url" {
  value = "${module.master_elb.elb_dns_name}"
}

output "baile_elb_url" {
  value = "${module.baile_elb.elb_dns_name}"
}

output "um_elb_url" {
  value = "${module.um_elb.elb_dns_name}"
}
