variable "dns_zone_id" {}

variable "base_domain" {}

variable "state_bucket" {}

variable "cluster_name" {}

variable "ssh_key" {
  default = "default_key"
}

variable "etcd_container_image" {
  default = "quay.io/coreos/etcd:latest"
}

variable "kubernetes_version" {
  default = "v1.6.4"
}

variable "hyperkube_image" {
  default = "quay.io/coreos/hyperkube:v1.6.4_coreos.0"
}

variable "etcd_instances" {
  default = 3
}

variable "etcd_instance_size" {
  default = "t2.small"
}

variable "worker_instance_size" {
  default = "t2.small"
}

variable "master_instance_size" {
  default = "t2.small"
}

variable "vpc_name" {
  default = "default"
}

variable "vpc_cidr_blocks" {
  type = "list"

  default = [
    "10.0.0.0/20",
    "10.0.16.0/20",
    "10.0.32.0/20",
  ]
}

output "api_server" {
  //  value = "${module.master.api_server}"
  value = "api.default.coldog.xyz"
}

variable "node_network" {
  description = "The CIDR network to use for the entire cluster. This must contain the node IPs and the pod IPs."
  default     = "10.0.0.0/8"
}

variable "pod_network" {
  description = "The CIDR network to use for pod IPs. Each pod launched in the cluster will be assigned an IP out of this range. This network must be routable between all hosts in the cluster. In a default installation, the flannel overlay network will provide routing to this network."
  default     = "10.2.0.0/16"
}

variable "service_ip_range" {
  description = "The CIDR network to use for service cluster VIPs (Virtual IPs). Each service will be assigned a cluster IP out of this range. This must not overlap with any IP ranges assigned to the POD_NETWORK, or other existing network infrastructure. Routing to these VIPs is handled by a local kube-proxy service to each host, and are not required to be routable between hosts."
  default     = "10.3.0.0/24"
}

variable "k8s_service_ip" {
  description = "The VIP (Virtual IP) address of the Kubernetes API Service. If the SERVICE_IP_RANGE is changed above, this must be set to the first IP in that range."
  default     = "10.3.0.1"
}

variable "dns_service_ip" {
  description = "The VIP (Virtual IP) address of the cluster DNS service. This IP must be in the range of the SERVICE_IP_RANGE and cannot be the first IP in the range. This same IP must be configured on all worker nodes to enable DNS service discovery."
  default     = "10.3.0.10"
}
