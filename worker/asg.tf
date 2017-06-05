module "node" {
  source             = "../node"
  kubernetes_version = "${var.kubernetes_version}"
  state_bucket       = "${var.state_bucket}"
  etcd_nodes         = "${var.etcd_nodes}"
}

resource "aws_launch_configuration" "worker" {
  name                 = "${var.cluster_name}_worker_lc.${uuid()}"
  image_id             = "${module.node.ami}"
  instance_type        = "${var.instance_size}"
  key_name             = "${var.ssh_key}"
  iam_instance_profile = "${var.iam_profile}"
  security_groups      = ["${var.autoscaling_sgs}"]

  associate_public_ip_address = true
  user_data                   = "${module.node.worker_config}"

  lifecycle {
    ignore_changes        = ["name"]
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name                 = "${var.cluster_name}_worker_asg"
  max_size             = "${var.max}"
  min_size             = "${var.min}"
  desired_capacity     = "${var.desired}"
  launch_configuration = "${aws_launch_configuration.worker.id}"
  force_delete         = true
  vpc_zone_identifier  = ["${var.subnets}"]
  termination_policies = ["OldestLaunchConfiguration"]

  tag {
    key                 = "cluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_worker"
    propagate_at_launch = true
  }
}

resource "aws_instance" "canary_node" {
  ami   = "${module.node.ami}"

  instance_type           = "t2.small"
  subnet_id               = "${var.subnets[0]}"
  key_name                = "${var.ssh_key}"
  vpc_security_group_ids  = ["${var.autoscaling_sgs}"]
  disable_api_termination = true

  iam_instance_profile = "${var.iam_profile}"

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["ami"]
  }

  tags {
    Name = "${var.cluster_name}_canary"
  }
}
