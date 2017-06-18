resource "aws_security_group" "master_lb" {
  name        = "${var.vpc_name}_master_lb"
  description = "Master LB security group."
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
    VPC = "${var.vpc_name}"
  }
}

resource "aws_security_group" "master" {
  name        = "${var.vpc_name}_master"
  description = "Master security group. Allows API server ingress."
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  ingress {
    from_port       = 6199
    to_port         = 6199
    protocol        = "tcp"
    security_groups = ["${aws_security_group.master_lb.id}"]
  }

  tags {
    VPC = "${var.vpc_name}"
  }
}

resource "aws_security_group" "worker" {
  name        = "${var.vpc_name}_worker"
  description = "Internal worker security group."
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    VPC = "${var.vpc_name}"
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
    VPC  = "${var.vpc_name}"
  }
}
