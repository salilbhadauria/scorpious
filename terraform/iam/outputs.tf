# vim: ts=4:sw=4:et:ft=hcl

output "bastion_iam_role_name" {
    value = "${aws_iam_role.bastion_role.name}"
}
output "nat_instance_iam_role_name" {
    value = "${aws_iam_role.nat_instance_role.name}"
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
