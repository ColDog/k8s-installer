variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "state_bucket" {}

variable "kubernetes_version" {}

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
