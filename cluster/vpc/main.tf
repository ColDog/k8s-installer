variable "vpc_name" {}

variable "state_bucket" {}

variable "cidr" {
  default = "10.0.0.0/16"
}

output "subnet_ids" {
  value = ["${aws_subnet.main_subnets.*.id}"]
}

output "sg_external_lb_https" {
  value = "${aws_security_group.external_lb_https.id}"
}

output "sg_instance_lb_https" {
  value = "${aws_security_group.instance_lb_https.id}"
}

output "sg_internal_instance" {
  value = "${aws_security_group.internal_instance.id}"
}

output "sg_ssh" {
  value = "${aws_security_group.ssh.id}"
}

output "id" {
  value = "${aws_vpc.main_vpc.id}"
}
