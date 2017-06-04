variable "cluster_name" {
  default = "default"
}

output "etcd_profile" {
  value = "${aws_iam_instance_profile.etcd_profile.name}"
}

output "master_profile" {
  value = "${aws_iam_instance_profile.master_profile.name}"
}
