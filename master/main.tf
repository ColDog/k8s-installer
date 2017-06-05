variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "kubernetes_version" {}

variable "etcd_nodes" {
  type = "list"
}

variable "iam_profile" {}

variable "state_bucket" {
  type = "string"
}

variable "instance_size" {}

variable "ssh_key" {}

variable "autoscaling_sgs" {
  type = "list"
}

variable "elb_sgs" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

variable "max" {
  default = 1
}

variable "min" {
  default = 1
}

variable "desired" {
  default = 1
}

output "api_server" {
  value = "${aws_route53_record.api_server.fqdn}"
}
