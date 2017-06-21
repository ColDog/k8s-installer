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

output "etcd_nodes" {
  value = ["${formatlist("http://%s:2379", aws_route53_record.etc_a_nodes.*.fqdn)}"]
}

output "provision_node_ip" {
  value = "${aws_instance.etcd_node.*.public_ip[0]}"
}
