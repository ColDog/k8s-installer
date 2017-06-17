variable "base_domain" {
  description = "Route53 public zone to setup entries."
}

variable "cluster_name" {
  description = "Kubernetes cluster name, this will prefix the domain name and all resources."
}

variable "asset_bucket" {
  description = "Asset bucket name. Must be created already."
}

variable "vault_addr" {
  description = "Vault HTTPS endpoint."
}

variable "api_prefix" {
  default = "k8s"
  description = "API server DNS name prefix, computed to <api_prefix>.<cluster>.<base_domain>"
}

variable "ssh_key" {
  default     = "default_key"
  description = "SSH key name, this should be created in the aws dashboard."
}

variable "etcd_container_image" {
  default     = "quay.io/coreos/etcd:latest"
  description = "Etcd container image, used to launch the etcd containers. Kept at latest by default."
}

variable "kubernetes_version" {
  default     = "v1.6.4"
  description = "Kubernetes version, this is used across all Kubernetes services."
}

variable "flanneld_version" {
  default     = "v0.7.1"
  description = "Flanneld version."
}

variable "cni_version" {
  default     = "v0.5.2"
  description = "CNI version."
}

variable "etcd_instances" {
  default     = 3
  description = "Count of etcd instances to launch, each will be identified by index etc0 - n."
}

variable "etcd_instance_size" {
  default     = "t2.small"
  description = "AWS EC2 instance size."
}

variable "worker_instances" {
  type = "map"
  default = {
    "min" = 1,
    "max" = 1,
    "desired" = 1,
  }
  description = "Worker autoscaling group defaults."
}


variable "worker_instance_size" {
  default     = "t2.small"
  description = "AWS EC2 instance size."
}

variable "master_instances" {
  type = "map"
  default = {
    "min" = 1,
    "max" = 1,
    "desired" = 1,
  }
  description = "Master autoscaling group defaults."
}

variable "master_instance_size" {
  default     = "t2.small"
  description = "AWS EC2 instance size."
}

variable "node_network" {
  default     = "10.0.0.0/16"
  description = "The CIDR network to use for the entire cluster. This must contain the node IPs and the pod IPs."
}

variable "pod_network" {
  default     = "10.2.0.0/16"
  description = "The CIDR network to use for pod IPs. Each pod launched in the cluster will be assigned an IP out of this range. This network must be routable between all hosts in the cluster. In a default installation, the flannel overlay network will provide routing to this network."
}

variable "service_ip_range" {
  default     = "10.3.0.0/24"
  description = "The CIDR network to use for service cluster VIPs (Virtual IPs). Each service will be assigned a cluster IP out of this range. This must not overlap with any IP ranges assigned to the POD_NETWORK, or other existing network infrastructure. Routing to these VIPs is handled by a local kube-proxy service to each host, and are not required to be routable between hosts."
}

variable "api_service_ip" {
  default     = "10.3.0.1"
  description = "The VIP (Virtual IP) address of the Kubernetes API Service. If the SERVICE_IP_RANGE is changed above, this must be set to the first IP in that range."
}

variable "dns_service_ip" {
  default     = "10.3.0.10"
  description = "The VIP (Virtual IP) address of the cluster DNS service. This IP must be in the range of the SERVICE_IP_RANGE and cannot be the first IP in the range. This same IP must be configured on all worker nodes to enable DNS service discovery."
}

output "k8s_api" {
  value = "https://${var.api_prefix}.${var.cluster_name}.${var.base_domain}"
}
