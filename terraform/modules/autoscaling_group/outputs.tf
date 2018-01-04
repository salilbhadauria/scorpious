# vim: ts=4:sw=4:et:ft=hcl

output "asg_name" {
  value = "${aws_autoscaling_group.asg.name}"
}
