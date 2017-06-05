variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "api_server" {}

variable "state_bucket" {}

variable "cluster_domain" {}

variable "cluster_cidr" {}

variable "instance_size" {}

variable "ssh_key" {}

variable "autoscaling_sgs" {
  type = "list"
}

variable "iam_worker_profile_id" {}

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
  value = "${data.ignition_config.worker.rendered}"
}
