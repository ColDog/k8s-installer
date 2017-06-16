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

resource "aws_instance" "vault_node" {
  count = "${var.instances}"
  ami   = "${data.aws_ami.coreos_ami.image_id}"

  instance_type           = "${var.instance_type}"
  key_name                = "${var.ssh_key}"
  subnet_id               = "${data.aws_subnet_ids.vault.ids[count.index]}"
  disable_api_termination = false
  user_data               = "${data.ignition_config.vault.rendered}"
  security_groups         = ["${aws_security_group.instance.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.vault_profile.id}"

  lifecycle {
    # Ignore changes in the AMI which force recreation of the resource. This
    # avoids accidental deletion of nodes whenever a new CoreOS Release comes
    # out.
    ignore_changes = ["ami", "security_groups"]
  }

  tags {
    Name = "vault_${count.index}"
  }
}
