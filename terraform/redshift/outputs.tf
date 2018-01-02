# vim: ts=4:sw=4:et:ft=hcl

output "redshift_master_username" {
  value = "${var.redshift_master_username}"
}
output "redshift_master_password" {
  value = "${random_string.redshift_password.result}"
}
output "redshift_url" {
  value = "${element(split(":", aws_redshift_cluster.redshift-clstr.endpoint), 0)}"
}
output "redshift_cluster_identifier" {
  value = "${aws_redshift_cluster.redshift-clstr.cluster_identifier}"
}
