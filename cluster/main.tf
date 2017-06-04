variable "dns_zone_id" {
  type = "string"
}

variable "base_domain" {
  type = "string"
}

variable "state_bucket" {
  type = "string"
}

variable "cluster_name" {
  type    = "string"
}

variable "etcd_cl_channel" {
  type    = "string"
  default = "stable"
}

variable "etcd_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "etcd_ssh_key_name" {
  type    = "string"
  default = "default_key"
}

variable "etcd_container_image" {
  type    = "string"
  default = "quay.io/coreos/etcd:latest"
}

variable "etcd_instances" {
  type    = "string"
  default = 3
}

variable "vpc_name" {
  type    = "string"
  default = "default"
}

variable "vpc_cidr_blocks" {
  type = "list"

  default = [
    "10.0.0.0/24",
    "10.1.0.0/24",
    "10.2.0.0/24",
  ]
}

output "kube_api_domain" {
  value = "${module.master.api_server}"
}

output "base_domain" {
  value = "${var.base_domain}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "state_bucket" {
  value = "${var.state_bucket}"
}
