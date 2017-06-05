module "vpc" {
  source = "../vpc"

  vpc_name    = "${var.vpc_name}"
  cidr_blocks = "${var.vpc_cidr_blocks}"
}

module "iam" {
  source = "../iam"

  cluster_name = "${var.cluster_name}"
}

module "assets" {
  source = "../assets"

  vpc_id             = "${module.vpc.id}"
  state_bucket       = "${var.state_bucket}"
  kubernetes_version = "${var.kubernetes_version}"
}

module "etcd" {
  source = "../etcd"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  subnets             = ["${module.vpc.subnet_ids}"]
  iam_etcd_profile_id = "${module.iam.etcd_profile}"

  security_groups     = [
    "${module.vpc.sg_internal_instance}",
    "${module.vpc.sg_ssh}",
  ]

  container_image = "${var.etcd_container_image}"
  instances       = "${var.etcd_instances}"

  instance_type = "${var.etcd_instance_size}"
  ssh_key       = "${var.ssh_key}"
}

module "master" {
  source = "../master"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"
  state_bucket = "${var.state_bucket}"

  subnets               = ["${module.vpc.subnet_ids}"]
  elb_sgs               = ["${module.vpc.sg_external_lb_https}"]
  iam_master_profile_id = "${module.iam.master_profile}"

  autoscaling_sgs       = [
    "${module.vpc.sg_internal_instance}",
    "${module.vpc.sg_instance_lb_https}",
    "${module.vpc.sg_ssh}",
  ]

  etcd_nodes       = ["${module.etcd.etcd_nodes}"]

  ignition_files = "${module.assets.ignition_files}"

  hyperkube_image = "${var.hyperkube_image}"

  instance_size = "${var.master_instance_size}"
  ssh_key       = "${var.ssh_key}"

  cluster_cidr = "10.200.0.0/16"
  service_cluster_ip_range = "10.32.0.0/24"
}

module "worker" {
  source = "../worker"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"
  state_bucket = "${var.state_bucket}"
  api_server   = "api.${var.cluster_name}.${var.base_domain}"

  subnets               = ["${module.vpc.subnet_ids}"]
  iam_worker_profile_id = "${module.iam.worker_profile}"

  autoscaling_sgs       = [
    "${module.vpc.sg_internal_instance}",
    "${module.vpc.sg_instance_lb_https}",
    "${module.vpc.sg_ssh}",
  ]

  cluster_cidr = "10.200.0.0/16"
  cluster_domain = "${var.base_domain}"

  ignition_files = "${module.assets.ignition_files}"

  instance_size = "${var.worker_instance_size}"
  ssh_key       = "${var.ssh_key}"
}
