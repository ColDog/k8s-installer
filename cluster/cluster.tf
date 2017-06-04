//module "vpc" {
//  source = "../vpc"
//
//  vpc_name    = "${var.vpc_name}"
//  cidr_blocks = "${var.vpc_cidr_blocks}"
//}

module "iam" {
  source = "../iam"

  cluster_name = "${var.cluster_name}"
}

module "assets" {
  source = "../assets"

  vpc_id = "vpc-f2b2f696"
  state_bucket = "${var.state_bucket}"
}

//module "etcd" {
//  source = "../etcd"
//
//  dns_zone_id  = "${var.dns_zone_id}"
//  base_domain  = "${var.base_domain}"
//  cluster_name = "${var.cluster_name}"
//
//  subnets = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]
//
//  security_groups = ["sg-6fea8209"]
//
//  cl_channel      = "${var.etcd_cl_channel}"
//  container_image = "${var.etcd_container_image}"
//
//  instances = "${var.etcd_instances}"
//
//  iam_etcd_profile_id = "${module.iam.etcd_profile}"
//}

//module "master" {
//  source = "../master"
//
//  dns_zone_id  = "${var.dns_zone_id}"
//  base_domain  = "${var.base_domain}"
//  cluster_name = "${var.cluster_name}"
//  state_bucket = "${var.state_bucket}"
//
//  subnets = ["${module.vpc.subnet_ids}"]
//
//  autoscaling_sgs = ["${module.vpc.sg_internal_instance}", "${module.vpc.sg_instance_lb_https}"]
//  elb_sgs         = ["${module.vpc.sg_external_lb_https}}"]
//
//  cluster_ip_range = "10.0.0.0/16"
//
//  etcd_nodes = ["${module.etcd.etcd_nodes}"]
//
//  iam_master_profile_id = "${module.iam.master_profile}"
//}

module "worker" {
  source = "../worker"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"
  state_bucket = "${var.state_bucket}"
  api_server   = "api.${var.cluster_name}.${var.base_domain}"

  subnets = ["subnet-fef2879a", "subnet-016ce077", "subnet-5214c00a"]

  autoscaling_sgs = ["sg-6fea8209"]
  iam_worker_profile_id = "${module.iam.worker_profile}"

  cluster_cidr   = "10.0.0.0/16"
  dns_zone_id    = "${var.dns_zone_id}"
  cluster_domain = "${var.base_domain}"

  ignition_files = "${module.assets.ignition_files}"
}
