resource "aws_route53_record" "api_server" {
  zone_id = "${var.dns_zone_id}"
  name    = "k8s.${var.cluster_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_api.dns_name}"
    zone_id                = "${aws_elb.master_api.zone_id}"
    evaluate_target_health = false
  }
}
