provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "state.default.coldog.xyz"
    key    = "cluster-state/"
    region = "us-west-2"
  }
}

variable "state_bucket" {}
variable "cluster_name" {}
variable "dns_zone_id" {}
variable "base_domain" {}

module "cluster" {
  source = "./cluster"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  state_bucket = "${var.state_bucket}"
  cluster_name = "${var.cluster_name}"
}
