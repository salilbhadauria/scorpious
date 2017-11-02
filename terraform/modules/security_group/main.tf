# vim: ts=4:sw=4:et:ft=hcl

###############################################################################
# << Security group

resource "aws_security_group" "sg" {

    vpc_id      = "${var.vpc_id}"
    name        = "${var.sg_name}"
    description = "${var.sg_description}"

    tags = "${merge(var.tags, map(
            "Name", format("%s-sg-%s-%s", 
                var.sg_name, 
                var.tags["owner"], 
                var.tags["environment"]
            )
        )
    )}"
}

###############################################################################
# << Security group rules for ingress

## CIDR source rules
#
# Example:
# [
#   { 
#       protocol   = "tcp",
#       from_port  = "80",
#       to_port    = "80",
#       cidr_block = "10.10.10.1, 10.10.10.2"
#       desc      = "Some description"
#   },
#   { ... }
# ]
#
#
resource "aws_security_group_rule" "ingress_rule_cidr" {
    count = "${length(var.ingress_rules_cidr)}"

    security_group_id = "${aws_security_group.sg.id}"
    type              = "ingress"
    from_port         = "${lookup(var.ingress_rules_cidr[count.index], "from_port")}"
    to_port           = "${lookup(var.ingress_rules_cidr[count.index], "to_port")}"
    protocol          = "${lookup(var.ingress_rules_cidr[count.index], "protocol")}"
    cidr_blocks       = [ "${split(", ", lookup(var.ingress_rules_cidr[count.index], "cidr_blocks"))}" ]
    description       = "${lookup(var.ingress_rules_cidr[count.index], "description", "_")}"
}

## Security Group ID
# Example:
# [
#   { 
#       protocol  = "tcp",
#       from_port = "80",
#       to_port   = "80",
#       sg_ids    = "10.10.10.1, 10.10.10.2"
#       desc      = "Some description"
#   },
#   { ... }
# ]
#
#

resource "aws_security_group_rule" "ingress_rule_sgid" {
    count = "${length(var.ingress_rules_sgid)}"

    security_group_id        = "${aws_security_group.sg.id}"
    type                     = "ingress"
    from_port                = "${lookup(var.ingress_rules_sgid[count.index], "from_port")}"
    to_port                  = "${lookup(var.ingress_rules_sgid[count.index], "to_port")}"
    protocol                 = "${lookup(var.ingress_rules_sgid[count.index], "protocol")}"
    source_security_group_id = [ "${split(", ", lookup(var.ingress_rules_sgid[count.index], "sg_ids"))}" ]
    description              = "${lookup(var.ingress_rules_sgid[count.index], "description", "_")}"
}

## Egress

resource "aws_security_group_rule" "egress_rule_cidr" {
    count = "${length(var.egress_rules_cidr)}"

    security_group_id = "${aws_security_group.sg.id}"
    type              = "egress"
    from_port         = "${lookup(var.egress_rules_cidr[count.index], "from_port")}"
    to_port           = "${lookup(var.egress_rules_cidr[count.index], "to_port")}"
    protocol          = "${lookup(var.egress_rules_cidr[count.index], "protocol")}"
    cidr_blocks       = [ "${split(", ", lookup(var.egress_rules_cidr[count.index], "cidr_blocks"))}" ]
    description       = "${lookup(var.egress_rules_cidr[count.index], "description", "_")}"
}

resource "aws_security_group_rule" "egress_rule_sgid" {
    count = "${length(var.egress_rules_sgid)}"

    security_group_id        = "${aws_security_group.sg.id}"
    type                     = "egress"
    from_port                = "${lookup(var.egress_rules_sgid[count.index], "from_port")}"
    to_port                  = "${lookup(var.egress_rules_sgid[count.index], "to_port")}"
    protocol                 = "${lookup(var.egress_rules_sgid[count.index], "protocol")}"
    source_security_group_id = [ "${split(", ", lookup(var.egress_rules_sgid[count.index], "sg_ids"))}" ]
    description              = "${lookup(var.egress_rules_sgid[count.index], "description", "_")}"
}

