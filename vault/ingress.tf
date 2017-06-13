data "aws_vpc" "vault" {
  default = true
}

data "aws_subnet_ids" "vault" {
  vpc_id = "${data.aws_vpc.vault.id}"
}

data "aws_acm_certificate" "main" {
  domain = "${var.domain}"
}

resource "aws_route53_record" "vault" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.vault.dns_name}"
    zone_id                = "${aws_elb.vault.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_elb" "vault" {
  name            = "vault"
  subnets         = ["${data.aws_subnet_ids.vault.ids}"]
  internal        = false
  security_groups = ["${aws_security_group.lb.id}"]

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "${data.aws_acm_certificate.main.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/v1/sys/health"
    interval            = 15
  }
}

resource "aws_elb_attachment" "vault" {
  count    = "${var.instances}"
  elb      = "${aws_elb.vault.id}"
  instance = "${aws_instance.vault_node.*.id[count.index]}"
}
