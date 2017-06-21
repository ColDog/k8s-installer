variable "etcd_nodes" {
  type = "list"
}

variable "kubernetes_version" {}

variable "flanneld_version" {}

variable "cni_version" {}

variable "cluster_name" {}

variable "api_server" {}

variable "vault_addr" {}

variable "node_network" {}

variable "pod_network" {}

variable "service_ip_range" {}

variable "api_service_ip" {}

variable "dns_service_ip" {}

variable "asset_bucket" {}

variable "etcd_provision_ip" {}

variable "ssh_key" {}

output "worker_config" {
  value = "${data.ignition_config.worker_remote.rendered}"
}

output "master_config" {
  value = "${data.ignition_config.master_remote.rendered}"
}

output "ami" {
  value = "${data.aws_ami.coreos_ami.id}"
}
