module "vpc" {
  source = "../vpc"

  vpc_name     = "${var.vpc_name}"
  cidr_blocks  = "${var.vpc_cidr_blocks}"
  state_bucket = "${var.state_bucket}"
}

module "iam" {
  source = "../iam"

  cluster_name = "${var.cluster_name}"
}

module "etcd" {
  source = "../etcd"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  subnets             = ["${module.vpc.subnet_ids}"]
  iam_etcd_profile_id = "${module.iam.etcd_profile}"

  security_groups = [
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

  subnets     = ["${module.vpc.subnet_ids}"]
  elb_sgs     = ["${module.vpc.sg_external_lb_https}"]
  iam_profile = "${module.iam.master_profile}"

  autoscaling_sgs = [
    "${module.vpc.sg_internal_instance}",
    "${module.vpc.sg_instance_lb_https}",
    "${module.vpc.sg_ssh}",
  ]

  instance_size = "${var.master_instance_size}"
  ssh_key       = "${var.ssh_key}"

  etcd_nodes         = ["${module.etcd.etcd_nodes}"]

  kubernetes_version = "${var.kubernetes_version}"
  cni_version = "${var.cni_version}"
  flanneld_version = "${var.flanneld_version}"

  dns_service_ip   = "${var.dns_service_ip}"
  node_network     = "${var.node_network}"
  service_ip_range = "${var.service_ip_range}"
  pod_network      = "${var.pod_network}"
}

module "worker" {
  source = "../worker"

  dns_zone_id  = "${var.dns_zone_id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"
  state_bucket = "${var.state_bucket}"

  subnets     = ["${module.vpc.subnet_ids}"]
  iam_profile = "${module.iam.worker_profile}"

  autoscaling_sgs = [
    "${module.vpc.sg_internal_instance}",
    "${module.vpc.sg_ssh}",
  ]

  instance_size = "${var.worker_instance_size}"
  ssh_key       = "${var.ssh_key}"

  etcd_nodes         = ["${module.etcd.etcd_nodes}"]

  kubernetes_version = "${var.kubernetes_version}"
  cni_version = "${var.cni_version}"
  flanneld_version = "${var.flanneld_version}"

  api_server       = "${module.master.api_server}"
  dns_service_ip   = "${var.dns_service_ip}"
  node_network     = "${var.node_network}"
  service_ip_range = "${var.service_ip_range}"
  pod_network      = "${var.pod_network}"
}
