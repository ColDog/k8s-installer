data "aws_availability_zones" "zones" {}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "main_subnets" {
  count                   = "${length(data.aws_availability_zones.zones.names)}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${cidrsubnet(var.cidr, 4, count.index)}"
  availability_zone       = "${data.aws_availability_zones.zones.names[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.vpc_name}_${count.index}"
  }
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main_vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main_gateway.id}"
  }

  tags {
    Name = "${var.vpc_name}"
  }
}
