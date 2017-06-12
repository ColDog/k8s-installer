resource "aws_iam_instance_profile" "vault_profile" {
  name = "vault_profile"
  role = "${aws_iam_role.vault_role.name}"
}

resource "aws_iam_role" "vault_role" {
  name = "vault_role"
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
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

// TODO: lock these down more carefully...
resource "aws_iam_role_policy" "vault_policy" {
  name = "vault_policy"
  role = "${aws_iam_role.vault_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action" : [
        "s3:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "iam:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "ec2:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:*",
        "arn:aws:logs:*:*:log-group:*:log-stream:*"
      ]
    }
  ]
}
EOF
}
