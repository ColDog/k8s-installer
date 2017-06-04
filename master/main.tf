variable "dns_zone_id" {
  type = "string"
}

variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type    = "string"
  default = "default"
}

variable "hyperkube_image" {
  default = "quay.io/coreos/hyperkube:v1.6.4_coreos.0"
}

variable "cluster_ip_range" {
  default = "10.0.0.0/32"
}

variable "etcd_nodes" {
  type = "list"
}

variable "iam_master_profile_id" {}

variable "state_bucket" {
  type = "string"
}

variable "instance_size" {
  default = "t2.small"
}

variable "ssh_key" {
  default = "default_key"
}

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
