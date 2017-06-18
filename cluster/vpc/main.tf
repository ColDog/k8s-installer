variable "vpc_name" {}

variable "asset_bucket" {}

variable "cidr" {
  default = "10.0.0.0/16"
}

output "subnet_ids" {
  value = ["${aws_subnet.main_subnets.*.id}"]
}

output "sg_master_lb" {
  value = "${aws_security_group.master_lb.id}"
}

output "sg_master" {
  value = "${aws_security_group.master.id}"
}

output "sg_worker" {
  value = "${aws_security_group.worker.id}"
}

output "sg_ssh" {
  value = "${aws_security_group.ssh.id}"
}

output "id" {
  value = "${aws_vpc.main_vpc.id}"
}
