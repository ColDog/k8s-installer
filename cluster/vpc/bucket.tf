data "aws_region" "current" {
  current = true
}

resource "aws_vpc_endpoint" "s3_assoc" {
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id       = "${aws_vpc.main_vpc.id}"
}

data "aws_route_table" "main_vpc" {
  vpc_id = "${aws_vpc.main_vpc.id}"
}

resource "aws_vpc_endpoint_route_table_association" "s3_assoc" {
  route_table_id  = "${data.aws_route_table.main_vpc.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3_assoc.id}"
}

// todo: how to allow multiple vpc endpoints on this bucket?, need to 'append' to the bucket policy
resource "aws_s3_bucket_policy" "state_bucket" {
  bucket = "${var.asset_bucket}"

  policy = <<EOF
{
  "Id": "PolicyStateBucket",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCEAccess",
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.asset_bucket}/*",
      "Principal": "*",
      "Condition": {
        "StringEquals": {"aws:sourceVpce": "${aws_vpc_endpoint.s3_assoc.id}"}
      }
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.asset_bucket}"
  acl    = "private"
}
