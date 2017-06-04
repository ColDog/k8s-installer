variable "dns_zone_id" {
  type = "string"
}

variable "base_domain" {
  type = "string"
}

variable "cluster_name" {
  type    = "string"
  default = "default"
}

variable "api_server" {}

variable "cluster_domain" {}

variable "cluster_cidr" {}

variable "kubernetes_version" {
  default = "v1-6-4"
}

variable "state_bucket" {
  type = "string"
}

variable "instance_size" {
  default = "t2.small"
}

variable "ssh_key" {
  default = "default_key"
}

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
