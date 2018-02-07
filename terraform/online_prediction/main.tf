# vim: ts=4:sw=4:et:ft=hcl

terraform {
    required_version = ">= 0.10.7"
    backend "s3" {}
}

#########################################################
# S3 Bucket

resource "aws_s3_bucket" "online_prediction_bucket" {
  bucket = "${var.online_prediction_bucket}"
  acl    = "private"
  tags   = "${merge(local.tags, map("name", "${var.online_prediction_bucket}"))}"
  lifecycle {
      prevent_destroy = false
  }
}

# SNS

resource "aws_sns_topic" "online-prediction" {
  name = "online-prediction-${var.owner}-${var.environment}"
}

resource "aws_sns_topic_policy" "online-prediction" {
  arn = "${aws_sns_topic.test.arn}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Id": "s3-publish-to-sns",
    "Statement": [{
            "Effect": "Allow",
            "Principal": { "AWS" : "*" },
            "Action": [ "SNS:Publish" ],
            "Resource": "${aws_sns_topic.online-prediction.arn}",
            "Condition": {
                "ArnLike": {
                    "aws:SourceArn": "arn:${var.arn}:s3:*:*:${var.online_prediction_bucket}"
                }
            }
    }]
  }
EOF
}

resource "aws_s3_bucket_notification" "online_prediction" {
  bucket = "${var.online_prediction_bucket}"

  topic {
    topic_arn     = "${aws_sns_topic.online-prediction.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}

# SQS

resource "aws_sqs_queue" "online_prediction" {
  name = "online-prediction-${var.owner}-${var.environment}"
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 300

  tags = "${merge(local.tags, map("name", "online-prediction"))}"
}

resource "aws_sqs_queue_policy" "online_prediction" {
  queue_url = "${aws_sqs_queue.online_prediction.id}"

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Effect":"Allow",
        "Principal": { "AWS": "*" },
        "Action":"sqs:SendMessage",
        "Resource":"${aws_sqs_queue.online_prediction.arn}",
        "Condition":{
          "ArnEquals":{
            "aws:SourceArn":"${aws_sns_topic.online-prediction.arn}"
          }
        }
      }
    ]
  }
EOF
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.online-prediction.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.online_prediction.arn}"
}

