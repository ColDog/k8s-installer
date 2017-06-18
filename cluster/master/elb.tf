resource "aws_elb" "master_api" {
  name            = "${var.cluster_name}-api-public" // only allows hyphens
  subnets         = ["${var.subnets}"]
  internal        = false
  security_groups = ["${var.elb_sgs}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:6199/healthz"
    interval            = 15
  }

  tags {
    cluster = "${var.cluster_name}"
  }
}
