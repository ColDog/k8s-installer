output "subnet_ids" {
  value = ["${aws_subnet.main_subnets.*.id}"]
}

output "sg_external" {
  value = "${aws_security_group.external.id}"
}

output "sg_internal" {
  value = "${aws_security_group.internal.id}"
}

output "sg_ssh" {
  value = "${aws_security_group.ssh.id}"
}
