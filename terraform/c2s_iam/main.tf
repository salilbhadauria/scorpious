# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# IAM Users
## Users and Policies

resource "aws_iam_user" "app" {
  name = "${var.tag_owner}-${var.environment}-app"
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
        "${local.arn}:s3:::${var.dcos_apps_bucket}",
        "${local.arn}:s3:::${var.dcos_apps_bucket}/*"
      ]
    }
  ]
}
EOF
}

#########################################################
# IAM Roles
## Role and Policies

resource "aws_iam_role" "bastion_role" {
    name = "${var.tag_owner}-${var.environment}-bastion_role"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service":[
                "ec2.amazonaws.com",
                "ssm.amazonaws.com"
              ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_attach" {
    role       = "${aws_iam_role.bastion_role.name}"
    policy_arn = "${local.arn}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role" "bootstrap_role" {
  name = "${var.tag_owner}-${var.environment}-bootstrap_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service":[
                "ec2.amazonaws.com",
                "ssm.amazonaws.com"
              ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bootstrap_ssm_attach" {
    role       = "${aws_iam_role.bootstrap_role.name}"
    policy_arn = "${local.arn}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "bootstrap_policy" {
  name = "${var.tag_owner}-${var.environment}-bootstrap_policy"
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
  name = "${var.tag_owner}-${var.environment}-master_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service":[
                "ec2.amazonaws.com",
                "ssm.amazonaws.com"
              ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "master_ssm_attach" {
    role       = "${aws_iam_role.master_role.name}"
    policy_arn = "${local.arn}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "master_policy" {
  name = "${var.tag_owner}-${var.environment}-master_policy"
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
  name = "${var.tag_owner}-${var.environment}-slave_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service":[
                "ec2.amazonaws.com",
                "ssm.amazonaws.com"
              ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "slave_ssm_attach" {
    role       = "${aws_iam_role.slave_role.name}"
    policy_arn = "${local.arn}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "slave_policy" {
  name = "${var.tag_owner}-${var.environment}-slave_policy"
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
  name = "${var.tag_owner}-${var.environment}-captain_role"
  path = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service":[
                "ec2.amazonaws.com",
                "ssm.amazonaws.com"
              ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "captain_ssm_attach" {
    role       = "${aws_iam_role.captain_role.name}"
    policy_arn = "${local.arn}:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "captain_policy" {
  name = "${var.tag_owner}-${var.environment}-captain_policy"
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
