variable "dns_zone_id" {}

variable "base_domain" {}

variable "state_bucket" {}

variable "cluster_name" {}

variable "ssh_key" {
  default = "default_key"
}

variable "etcd_container_image" {
  default = "quay.io/coreos/etcd:latest"
}

variable "kubernetes_version" {
  default = "v1.6.4"
}

variable "hyperkube_image" {
  default = "quay.io/coreos/hyperkube:v1.6.4_coreos.0"
}

variable "etcd_instances" {
  default = 3
}

variable "etcd_instance_size" {
  default = "t2.small"
}

variable "worker_instance_size" {
  default = "t2.small"
}

variable "master_instance_size" {
  default = "t2.small"
}

variable "vpc_name" {
  default = "default"
}

variable "vpc_cidr_blocks" {
  type = "list"

  default = [
    "10.0.0.0/20",
    "10.0.16.0/20",
    "10.0.32.0/20",
  ]
}

output "api_server" {
  value = "${module.master.api_server}"
}
