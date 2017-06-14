resource "aws_vpc_endpoint" "s3_assoc" {
  service_name = "com.amazonaws.us-west-2.s3"
  vpc_id       = "${aws_vpc.main_vpc.id}"
}

data "aws_route_table" "main_vpc" {
  vpc_id = "${aws_vpc.main_vpc.id}"
}
