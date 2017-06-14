variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "kubernetes_version" {}

variable "cni_version" {}

variable "flanneld_version" {}

variable "etcd_nodes" {
  type = "list"
}

variable "instance_size" {}

variable "ssh_key" {}

variable "autoscaling_sgs" {
  type = "list"
}

variable "iam_profile" {}

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

variable "api_server" {}

variable "node_network" {}

variable "pod_network" {}

variable "service_ip_range" {}

variable "dns_service_ip" {}

variable "vault_addr" {}
