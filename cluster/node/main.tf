variable "etcd_nodes" {
  type = "list"
}

variable "state_bucket" {}

variable "kubernetes_version" {}

variable "flanneld_version" {}

variable "cni_version" {}

variable "cluster_name" {}

variable "api_server" {}

variable "vault_addr" {}

variable "node_network" {}

variable "pod_network" {}

variable "service_ip_range" {}

variable "dns_service_ip" {}

output "worker_config" {
  value = "${data.ignition_config.worker.rendered}"
}

output "master_config" {
  value = "${data.ignition_config.master.rendered}"
}

output "ami" {
  value = "${data.aws_ami.coreos_ami.id}"
}
