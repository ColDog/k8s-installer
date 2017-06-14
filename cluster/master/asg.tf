module "node" {
  source       = "../node"
  etcd_nodes   = "${var.etcd_nodes}"
  cluster_name = "${var.cluster_name}"
  api_server   = "${aws_route53_record.api_server.fqdn}"
  vault_addr   = "${var.vault_addr}"

  dns_service_ip   = "${var.dns_service_ip}"
  node_network     = "${var.node_network}"
  service_ip_range = "${var.service_ip_range}"
  pod_network      = "${var.pod_network}"

  kubernetes_version = "${var.kubernetes_version}"
  cni_version        = "${var.cni_version}"
  flanneld_version   = "${var.flanneld_version}"
}

resource "aws_launch_configuration" "master" {
  name                 = "${var.cluster_name}_master_lc.${uuid()}"
  image_id             = "${module.node.ami}"
  instance_type        = "${var.instance_size}"
  key_name             = "${var.ssh_key}"
  iam_instance_profile = "${var.iam_profile}"
  security_groups      = ["${var.autoscaling_sgs}"]

  associate_public_ip_address = true
  user_data                   = "${module.node.master_config}"

  lifecycle {
    ignore_changes        = ["name"]
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "master" {
  name                 = "${var.cluster_name}_master_asg"
  max_size             = "${var.max}"
  min_size             = "${var.min}"
  desired_capacity     = "${var.desired}"
  launch_configuration = "${aws_launch_configuration.master.id}"
  force_delete         = true
  vpc_zone_identifier  = ["${var.subnets}"]
  termination_policies = ["OldestLaunchConfiguration"]

  load_balancers = ["${aws_elb.master_api.id}"]

  tag {
    key                 = "cluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_master"
    propagate_at_launch = true
  }
}
