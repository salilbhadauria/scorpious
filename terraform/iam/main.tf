# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# IAM Roles
## Role and Policies

resource "aws_iam_role" "nat_instance_role" {
    name = "nat_instance_role"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "nat_instance_policy" {
    name = "nat_instance_policy"
    role = "${aws_iam_role.nat_instance_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "NATInstance",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:ModifyInstanceAttribute",
                "ec2:CreateRoute",
                "ec2:ReplaceRoute"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "bootstrap_role" {
  name = "bootstrap_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "bootstrap_policy" {
  name = "bootstrap_policy"
  role = "${aws_iam_role.bootstrap_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
