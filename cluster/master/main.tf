variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "kubernetes_version" {}

variable "cni_version" {}

variable "flanneld_version" {}

variable "etcd_nodes" {
  type = "list"
}

variable "iam_profile" {}

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

variable "node_network" {}

variable "pod_network" {}

variable "service_ip_range" {}

variable "api_service_ip" {}

variable "dns_service_ip" {}

variable "vault_addr" {}

output "api_server" {
  value = "${aws_route53_record.api_server.fqdn}"
}
