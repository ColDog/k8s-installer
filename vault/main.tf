variable "dns_zone_id" {}

variable "ssl_certificate_id" {}

variable "dns_name" {
  default = "vault"
}

variable "bucket" {}

variable "instance_type" {
  default = "t2.small"
}

variable "ssh_key" {
  default = "default_key"
}

variable "container_image" {
  default = "vault:latest"
}

variable "instances" {
  default = 1
}
