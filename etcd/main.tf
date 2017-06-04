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

variable "cl_channel" {
  type    = "string"
  default = "stable"
}

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "ssh_key_name" {
  type    = "string"
  default = "default_key"
}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "container_image" {
  type    = "string"
  default = "quay.io/coreos/etcd:latest"
}

variable "instances" {
  type    = "string"
  default = 3
}

variable "iam_etcd_profile_id" {}
