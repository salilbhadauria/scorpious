# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# IAM Users
## Users and Policies

resource "aws_iam_user" "app" {
  name = "${var.environment}-app"
  path = "/apps/"
}

resource "aws_iam_access_key" "app" {
  user = "${aws_iam_user.app.name}"
}

resource "aws_iam_user_policy" "app_s3" {
  name = "${var.environment}-app-user-policy"
  user = "${aws_iam_user.app.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${local.arn}:::${var.dcos_apps_bucket}",
        "${local.arn}:::${var.dcos_apps_bucket}/*"
      ]
    }
  ]
}
EOF
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

resource "aws_iam_role" "master_role" {
  name = "master_role"
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

resource "aws_iam_role_policy" "master_policy" {
  name = "master_policy"
  role = "${aws_iam_role.master_role.id}"
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

resource "aws_iam_role" "slave_role" {
  name = "slave_role"
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

resource "aws_iam_role_policy" "slave_policy" {
  name = "slave_policy"
  role = "${aws_iam_role.slave_role.id}"
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

resource "aws_iam_role" "captain_role" {
  name = "captain_role"
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

resource "aws_iam_role_policy" "captain_policy" {
  name = "captain_policy"
  role = "${aws_iam_role.captain_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
