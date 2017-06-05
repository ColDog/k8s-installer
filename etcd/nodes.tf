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

resource "aws_instance" "etcd_node" {
  count = "${var.instances}"
  ami   = "${data.aws_ami.coreos_ami.image_id}"

  instance_type           = "${var.instance_type}"
  subnet_id               = "${var.subnets[min(count.index, length(var.subnets)-1)]}"
  key_name                = "${var.ssh_key}"
  user_data               = "${data.ignition_config.etcd.*.rendered[count.index]}"
  vpc_security_group_ids  = ["${var.security_groups}"]
  disable_api_termination = true

  iam_instance_profile = "${var.iam_etcd_profile_id}"

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["ami"]
    prevent_destroy = true
  }

  tags {
    Name = "${var.cluster_name}_etcd${count.index}"
  }
}
