resource "aws_iam_instance_profile" "etcd_profile" {
  name = "${var.cluster_name}_etcd_profile"
  role = "${aws_iam_role.etcd_role.name}"

  provisioner "local-exec" {
    // The failure of this to propagate when etcd is launching requires that we sleep for x minutes here.
    command = "sleep 30"
  }
}

resource "aws_iam_role" "etcd_role" {
  name = "${var.cluster_name}_etcd_role"
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

resource "aws_iam_role_policy" "etcd_policy" {
  name = "${var.cluster_name}_etcd_policy"
  role = "${aws_iam_role.etcd_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action" : [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::*",
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
