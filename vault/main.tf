variable "dns_name" {
  default = "vault"
  description = "Subdomain name that vault will live under."
}

variable "domain" {
  description = "Domain to host vault service under, must be registered with Route53 and ACM."
}

variable "bucket" {
  description = "S3 bucket for storage backend."
}

variable "instance_type" {
  default = "t2.small"
  description = "EC2 instance size."
}

variable "ssh_key" {
  default = "default_key"
  description = "SSH Key for cluster access."
}

variable "container_image" {
  default = "vault:latest"
  description = "Docker container to run vault in."
}

variable "instances" {
  default = 1
  description = "Vault instance count, must be using a highly available backend."
}

output "instance_ips" {
  value = ["${aws_instance.vault_node.*.public_ip}"]
}

output "vault_host" {
  value = "${aws_route53_record.vault.fqdn}"
}
