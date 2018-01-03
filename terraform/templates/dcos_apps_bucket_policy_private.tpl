{
    "Version": "2012-10-17",
    "Id": "Policy1465839690447",
    "Statement": [
        {
            "Sid": "Stmt1465839687032",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${dcos_apps_bucket_arn}/static-content/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "${access_cidr}",
                        "${deploy_cidr}"
                    ]
                }
            }    
        },
        {    
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${dcos_apps_bucket_arn}/static-content/*",
            "Condition": {
                "StringEquals": {
                    "aws:sourceVpce": "${vpce_id}"
                }
            }
        }
    ]
}