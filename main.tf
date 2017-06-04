variable "dns_zone_id" {
  type = "string"
}

variable "base_domain" {
  type = "string"
}

variable "kube_api_domain" {
  type = "string"
}

variable "state_bucket" {
  type = "string"
}

variable "cluster_name" {
  type    = "string"
  default = "default"
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
  value = "${var.kube_api_domain}"
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

provider "aws" {
  region = "us-west-2"
}

//module "vpc" {
//  source = "./vpc"
//
//  vpc_name    = "${var.vpc_name}"
//  cidr_blocks = "${var.vpc_cidr_blocks}"
//}

module "iam" {
  source = "./iam"

  cluster_name = "${var.cluster_name}"
}

module "etcd" {
  source = "./etcd"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  //  subnets         = "${module.vpc.subnet_ids}"
  //  security_groups = "${module.vpc.sg_internal}"
  subnets = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]

  security_groups = ["sg-6fea8209"]

  cl_channel      = "${var.etcd_cl_channel}"
  container_image = "${var.etcd_container_image}"

  instances = "${var.etcd_instances}"

  iam_etcd_profile_id = "${module.iam.etcd_profile}"
}

module "master" {
  source = "./master"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  //  subnets         = "${module.vpc.subnet_ids}"
  //  autoscaling_sgs = "${module.vpc.sg_internal}"
  //  elb_sgs         = "${module.vpc.sg_external}"
  subnets = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]

  autoscaling_sgs = ["sg-6fea8209"]
  elb_sgs         = ["sg-6fea8209"]

  cluster_ip_range = "172.31.0.0/24"

  state_bucket = "${var.state_bucket}"
  etcd_nodes   = ["${module.etcd.etcd_nodes}"]

  iam_master_profile_id = "${module.iam.master_profile}"
}
