variable "vpc_id" {}

variable "state_bucket" {}

variable "kubernetes_version" {
  default = "v1.6.4"
}

output "ignition_files" {
  value = {
    kubelet_kubeconfig = "${data.ignition_file.kubelet_kubeconfig.id}"
    kubelet_pem = "${data.ignition_file.kubelet_pem.id}"
    kubelet_key_pem = "${data.ignition_file.kubelet_key_pem.id}"
    apiserver_pem = "${data.ignition_file.apiserver_pem.id}"
    apiserver_key_pem = "${data.ignition_file.apiserver_key_pem.id}"
    svcaccount_pem = "${data.ignition_file.svcaccount_pem.id}"
    svcaccount_key_pem = "${data.ignition_file.svcaccount_key_pem.id}"
    controller_kubeconfig = "${data.ignition_file.controller_kubeconfig.id}"
    controller_pem = "${data.ignition_file.controller_pem.id}"
    controller_key_pem = "${data.ignition_file.controller_key_pem.id}"
    kubelet_binary = "${data.ignition_file.kubelet_binary.id}"
    kubeproxy_binary = "${data.ignition_file.kubeproxy_binary.id}"
  }
}
