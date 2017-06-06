variable "etcd_nodes" {
  type = "list"
}

variable "state_bucket" {}

variable "kubernetes_version" {}

variable "cluster_name" {}

output "worker_config" {
  value = "${data.ignition_config.worker.rendered}"
}

output "master_config" {
  value = "${data.ignition_config.master.rendered}"
}

output "ami" {
  value = "${data.aws_ami.coreos_ami.id}"
}
