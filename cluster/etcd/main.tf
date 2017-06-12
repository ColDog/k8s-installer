variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "instance_type" {}

variable "ssh_key" {}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "container_image" {
  default = "quay.io/coreos/etcd:latest"
}

variable "instances" {
  default = 3
}

variable "iam_etcd_profile_id" {}
