# vim: ts=4:sw=4:et:ft=hcl

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}

