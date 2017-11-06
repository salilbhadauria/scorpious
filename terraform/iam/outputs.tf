# vim: ts=4:sw=4:et:ft=hcl

output "bootstrap_iam_role_name" {
    value = "${aws_iam_role.bootstrap_role.name}"
}
