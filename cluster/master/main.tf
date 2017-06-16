variable "ami" {}

variable "user_data" {}

variable "dns_zone_id" {}

variable "base_domain" {}

variable "cluster_name" {}

variable "iam_profile" {}

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
