# vim: ts=4:sw=4:et:ft=hcl

output "redshift_master_username" {
  value = "${var.redshift_master_username}"
}
output "redshift_master_password" {
  value = "${random_string.redshift_password.result}"
}
