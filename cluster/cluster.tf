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
  state_bucket = "${var.state_bucket}"

  subnets = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]

  autoscaling_sgs = ["sg-6fea8209"]
  elb_sgs         = ["sg-6fea8209"]

  cluster_ip_range = "172.31.0.0/24"

  etcd_nodes = ["${module.etcd.etcd_nodes}"]

  iam_master_profile_id = "${module.iam.master_profile}"
}

module "worker" {
  source = "./worker"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"
  state_bucket = "${var.state_bucket}"
  api_server   = "${module.master.api_server}"

  autoscaling_sgs       = ["sg-6fea8209"]
  iam_worker_profile_id = "${module.iam.worker_profile}"
  subnets               = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]

  cluster_cidr   = "172.31.0.0/24"
  dns_zone_id    = "${var.dns_zone_id}"
  cluster_domain = "${var.base_domain}"
}
