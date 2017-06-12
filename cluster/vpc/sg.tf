resource "aws_security_group" "external_lb_https" {
  name        = "${var.vpc_name}_external_lb"
  description = "External security group"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    vpc = "${var.vpc_name}"
  }
}

resource "aws_security_group" "instance_lb_https" {
  name        = "${var.vpc_name}_instance_lb_https"
  description = "Internal instance security group"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_lb_https.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    vpc = "${var.vpc_name}"
  }
}

resource "aws_security_group" "internal_instance" {
  name        = "${var.vpc_name}_internal_instance"
  description = "Internal security group"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    vpc = "${var.vpc_name}"
  }
}

resource "aws_security_group" "ssh" {
  name        = "${var.vpc_name}_ssh"
  description = "Instance ssh access"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.vpc_name}_ssh"
    VPC  = "${var.vpc_name}"
  }
}
