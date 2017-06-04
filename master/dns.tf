resource "aws_route53_record" "etcd_srv_discover" {
  zone_id = "${var.dns_zone_id}"
  name    = "api.${var.cluster_name}"
  type    = "A"
  alias {
    name                   = "${aws_elb.master_api.dns_name}"
    zone_id                = "${aws_elb.master_api.zone_id}"
    evaluate_target_health = false
  }
}
