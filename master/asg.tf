data "aws_ami" "coreos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["595879546273"]
  }
}

resource "random_id" "launch_config" {
  byte_length = 8
  keepers = {
    ignition_config = "${sha512(data.ignition_config.master.rendered)}"
  }
}

resource "aws_launch_configuration" "master" {
  name                 = "${var.cluster_name}_master_lc_${random_id.launch_config.hex}"
  image_id             = "${data.aws_ami.coreos_ami.id}"
  instance_type        = "${var.instance_size}"
  key_name             = "${var.ssh_key}"
  iam_instance_profile = "${var.iam_master_profile_id}"
  security_groups      = ["${var.autoscaling_sgs}"]

  associate_public_ip_address = true
  user_data = "${data.ignition_config.master_remote.rendered}"


  lifecycle {
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

