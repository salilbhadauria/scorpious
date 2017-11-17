# vim: ts=4:sw=4:et:ft=hcl

output "master_elb_url" {
  value = "${module.master_elb.elb_dns_name}"
}
