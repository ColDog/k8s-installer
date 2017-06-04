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

variable "kubernetes_binary_verification" {
  type = "map"

  default = {
    kube-proxy = "sha512-6f9f22b9ce68fa53e40fbecc7ed4231715d2687fea239dc4e6f3e69b5bc089582122cb97f0e01a861da1794e264e0c114032d5d47a0abb403b654ac102ba9436"
    kubelet    = "sha512-303673b06a121ec326255a578252d285ea01845fe51fa956a52094cf87e78a85a46525bd470ae1471274f2c9df05eef62f02839d68922d2b8efe6b48bff18a7c"
  }
}

variable "kubernetes_version" {
  default = "v1.6.4"
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
