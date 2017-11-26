# vim: ts=4:sw=4:et:ft=hcl

output "nat_instance_iam_role_name" {
    value = "${aws_iam_role.nat_instance_role.name}"
}

output "bootstrap_iam_role_name" {
    value = "${aws_iam_role.bootstrap_role.name}"
}
