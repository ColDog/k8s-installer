data "aws_route53_zone" "main" {
  name = "${var.base_domain}"
}

module "vault" {
  source       = "./vault"

  cluster_name = "${var.cluster_name}"
}

module "vpc" {
  source = "./vpc"

  vpc_name     = "${var.cluster_name}"
  cidr         = "${var.node_network}"
  asset_bucket = "${var.asset_bucket}"
}

module "iam" {
  source = "./iam"

  cluster_name = "${var.cluster_name}"
}

module "etcd" {
  source = "./etcd"

  dns_zone_id  = "${data.aws_route53_zone.main.id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  subnets             = ["${module.vpc.subnet_ids}"]
  iam_etcd_profile_id = "${module.iam.etcd_profile}"

  security_groups = [
    "${module.vpc.sg_worker}",
    "${module.vpc.sg_ssh}",
  ]

  container_image = "${var.etcd_container_image}"
  instances       = "${var.etcd_instances}"

  instance_type = "${var.etcd_instance_size}"
  ssh_key       = "${var.ssh_key}"
}

module "node" {
  source = "./node"

  etcd_nodes   = "${module.etcd.etcd_nodes}"
  cluster_name = "${var.cluster_name}"
  api_server   = "${var.api_prefix}.${var.cluster_name}.${var.base_domain}"
  vault_addr   = "${var.vault_addr}"

  dns_service_ip   = "${var.dns_service_ip}"
  node_network     = "${var.node_network}"
  service_ip_range = "${var.service_ip_range}"
  api_service_ip   = "${var.api_service_ip}"
  pod_network      = "${var.pod_network}"

  kubernetes_version = "${var.kubernetes_version}"
  cni_version        = "${var.cni_version}"
  flanneld_version   = "${var.flanneld_version}"

  asset_bucket = "${var.asset_bucket}"
}

module "master" {
  source = "./master"

  dns_zone_id  = "${data.aws_route53_zone.main.id}"
  base_domain  = "${var.base_domain}"
  cluster_name = "${var.cluster_name}"

  subnets     = ["${module.vpc.subnet_ids}"]
  elb_sgs     = ["${module.vpc.sg_master_lb}"]
  iam_profile = "${module.iam.master_profile}"

  autoscaling_sgs = [
    "${module.vpc.sg_master}",
    "${module.vpc.sg_worker}",
    "${module.vpc.sg_ssh}",
  ]

  instance_size = "${var.master_instance_size}"
  ssh_key       = "${var.ssh_key}"

  user_data = "${module.node.master_config}"
  ami = "${module.node.ami}"

  min = "${var.master_instances["min"]}"
  max = "${var.master_instances["max"]}"
  desired = "${var.master_instances["desired"]}"
}

module "worker" {
  source = "./worker"

  cluster_name = "${var.cluster_name}"

  subnets     = ["${module.vpc.subnet_ids}"]
  iam_profile = "${module.iam.worker_profile}"

  autoscaling_sgs = [
    "${module.vpc.sg_worker}",
    "${module.vpc.sg_ssh}",
  ]

  instance_size = "${var.worker_instance_size}"
  ssh_key       = "${var.ssh_key}"

  user_data = "${module.node.worker_config}"
  ami = "${module.node.ami}"

  min = "${var.worker_instances["min"]}"
  max = "${var.worker_instances["max"]}"
  desired = "${var.worker_instances["desired"]}"
}
