data "ignition_file" "opts_worker" {
  path       = "/etc/kubernetes/options.env"
  mode       = 0755
  filesystem = "root"

  content {
    content = <<EOF
K8S_API=${var.api_server}
K8S_CLUSTER=${var.cluster_name}
K8S_VERSION=${var.kubernetes_version}
K8S_POD_NETWORK=${var.pod_network}
K8S_SERVICE_IP_RANGE=${var.service_ip_range}
K8S_API_SERVICE_IP=${var.api_service_ip}
K8S_DNS_SERVICE_IP=${var.dns_service_ip}
K8S_ETCD_NODES=${join(",", var.etcd_nodes)}
K8S_ROLE=worker

VAULT_ADDR=${var.vault_addr}
FLANNELD_VERSION=${var.flanneld_version}
CNI_VERSION=${var.cni_version}
ASSET_URL=https://${var.asset_bucket}.s3.amazonaws.com
EOF
  }
}

data "ignition_file" "opts_master" {
  path       = "/etc/kubernetes/options.env"
  mode       = 0755
  filesystem = "root"

  content {
    content = <<EOF
VAULT_ADDR=${var.vault_addr}
K8S_API=${var.api_server}
K8S_CLUSTER=${var.cluster_name}
K8S_VERSION=${var.kubernetes_version}
K8S_POD_NETWORK=${var.pod_network}
K8S_SERVICE_IP_RANGE=${var.service_ip_range}
K8S_API_SERVICE_IP=${var.api_service_ip}
K8S_DNS_SERVICE_IP=${var.dns_service_ip}
K8S_ETCD_NODES=${join(",", var.etcd_nodes)}
K8S_KUBELET_SCHEDULABLE=false
K8S_KUBELET_TAINTS=--register-with-taints=node-role.kubernetes.io/master=:NoSchedule
K8S_ROLE=master

FLANNELD_VERSION=${var.flanneld_version}
CNI_VERSION=${var.cni_version}
ASSET_URL=https://${var.asset_bucket}.s3.amazonaws.com
EOF
  }
}

data "ignition_file" "cni_opts" {
  filesystem = "root"
  path       = "/etc/cni/net.d/10-flannel.conf"

  content {
    content = <<EOF
{
  "name": "podnet",
  "type": "flannel",
  "delegate": {
    "isDefaultGateway": true
  }
}
EOF
  }
}

data "ignition_file" "vault_login" {
  path       = "/opt/bin/vault-login"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/vault-login.sh")}"
  }
}

data "ignition_file" "bootstrap_master" {
  path       = "/opt/bin/bootstrap-master"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/bootstrap-master.sh")}"
  }
}

data "ignition_file" "bootstrap_worker" {
  path       = "/opt/bin/bootstrap-worker"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/bootstrap-worker.sh")}"
  }
}

data "ignition_file" "get_kubeconfig" {
  path       = "/opt/bin/get-kubeconfig"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/get-kubeconfig.sh")}"
  }
}

data "ignition_file" "get_certs" {
  path       = "/opt/bin/get-certs"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/get-certs.sh")}"
  }
}

data "ignition_file" "get_servicekey" {
  path       = "/opt/bin/get-servicekey"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/get-servicekey.sh")}"
  }
}

data "ignition_file" "kubeproxy_installer" {
  path       = "/opt/bin/kubeproxy-installer"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/kubeproxy-installer.sh")}"
  }
}

data "ignition_file" "kubelet_installer" {
  path       = "/opt/bin/kubelet-installer"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/kubelet-installer.sh")}"
  }
}

data "ignition_file" "flanneld_installer" {
  path       = "/opt/bin/flanneld-installer"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/flanneld-installer.sh")}"
  }
}

data "ignition_file" "cni_installer" {
  path       = "/opt/bin/cni-installer"
  mode       = 0755
  filesystem = "root"

  content {
    content = "${file("${path.module}/scripts/cni-installer.sh")}"
  }
}
