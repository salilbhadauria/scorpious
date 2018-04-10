# vim: ts=4:sw=4:et:ft=hcl

output "bastion_iam_role_name" {
    value = "${aws_iam_role.bastion_role.name}"
}

# workaround used here to make nat output optional based on if its created or not
output "nat_instance_iam_role_name" {
    value = "${element(compact(concat(list(var.only_public == "true" ? "N/A" : ""), aws_iam_role.nat_instance_role.*.name)), 0)}"
}

output "bootstrap_iam_role_name" {
    value = "${aws_iam_role.bootstrap_role.name}"
}
output "master_iam_role_name" {
    value = "${aws_iam_role.master_role.name}"
}
output "slave_iam_role_name" {
    value = "${aws_iam_role.slave_role.name}"
}
output "captain_iam_role_name" {
    value = "${aws_iam_role.captain_role.name}"
}
output "app_access_key" {
    value = "${aws_iam_access_key.app.id}"
}
output "app_secret_key" {
    value = "${aws_iam_access_key.app.secret}"
}
output "app_user_name" {
    value = "${aws_iam_user.app.name}"
}
