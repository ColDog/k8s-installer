data "ignition_file" "options_env" {
  path       = "/etc/kubernetes/options.env"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
VAULT_ADDR=${var.vault_addr}
K8S_API=${var.api_server}
K8S_CLUSTER=${var.cluster_name}
K8S_VERSION=${var.kubernetes_version}
FLANNELD_VERSION=${var.flanneld_version}
CNI_VERSION=${var.cni_version}
EOF
  }
}

data "ignition_file" "vault_login" {
  path       = "/opt/bin/vault-login"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/vault-login.sh")}"
  }
}

data "ignition_file" "bootstrap_master" {
  path       = "/opt/bin/bootstrap-master"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/bootstrap-master.sh")}"
  }
}

data "ignition_file" "bootstrap_worker" {
  path       = "/opt/bin/bootstrap-worker"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/bootstrap-worker.sh")}"
  }
}

data "ignition_file" "get_kubeconfig" {
  path       = "/opt/bin/get-kubeconfig"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/get-kubeconfig.sh")}"
  }
}

data "ignition_file" "get_certs" {
  path       = "/opt/bin/get-certs"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/get-certs.sh")}"
  }
}

data "ignition_file" "get_kubeconfig" {
  path       = "/opt/bin/get-kubeconfig"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/get-kubeconfig.sh")}"
  }
}

data "ignition_file" "kubeproxy_installer" {
  path       = "/opt/bin/kubeproxy-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/kubeproxy-installer.sh")}"
  }
}

data "ignition_file" "kubelet_installer" {
  path       = "/opt/bin/kubelet-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/kubelet-installer.sh")}"
  }
}

data "ignition_file" "flanneld_installer" {
  path       = "/opt/bin/flanneld-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/flanneld-installer.sh")}"
  }
}

data "ignition_file" "cni_installer" {
  path       = "/opt/bin/cni-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("${module.path}/scripts/cni-installer.sh")}"
  }
}
