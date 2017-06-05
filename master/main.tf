variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "hyperkube_image" {}

variable "service_cluster_ip_range" {}

variable "cluster_cidr" {}

variable "etcd_nodes" {
  type = "list"
}

variable "iam_master_profile_id" {}

variable "state_bucket" {
  type = "string"
}

variable "instance_size" {}

variable "ssh_key" {}

variable "autoscaling_sgs" {
  type = "list"
}

variable "elb_sgs" {
  type = "list"
}

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

variable "ignition_files" {
  type = "map"
}

output "user_data" {
  value = "${data.ignition_config.master.rendered}"
}

output "api_server" {
  value = "${aws_route53_record.api_server.fqdn}"
}
