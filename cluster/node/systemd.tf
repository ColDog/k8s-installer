data "ignition_systemd_unit" "bootstrap_master" {
  name   = "bootstrap.service"
  enable = true
  content = "${file("${path.module}/systemd/bootstrap-master.service")}"

}

data "ignition_systemd_unit" "bootstrap_worker" {
  name   = "bootstrap.service"
  enable = true
  content = "${file("${path.module}/systemd/bootstrap-worker.service")}"
}

data "ignition_systemd_unit" "metadata" {
  name   = "coreos-metadata.service"
  enable = true
}

data "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true
}

data "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true
  content = "${file("${path.module}/systemd/kubelet.service")}"
}

data "ignition_systemd_unit" "kubeproxy" {
  name   = "kubeproxy.service"
  enable = true
  content = "${file("${path.module}/systemd/kubeproxy.service")}"
}

data "ignition_systemd_unit" "flanneld" {
  name   = "flannel.service"
  enable = true
  content = "${file("${path.module}/systemd/flanneld.service")}"
}

data "ignition_systemd_unit" "apiserver" {
  name   = "apiserver.service"
  enable = true
  content = "${file("${path.module}/systemd/apiserver.service")}"
}

data "ignition_systemd_unit" "controllermanager" {
  name   = "controllermanager.service"
  enable = true
  content = "${file("${path.module}/systemd/controllermanager.service")}"
}

data "ignition_systemd_unit" "scheduler" {
  name   = "scheduler.service"
  enable = true
  content = "${file("${path.module}/systemd/scheduler.service")}"
}

data "ignition_systemd_unit" "healthzmaster" {
  name   = "healthzmaster.service"
  enable = true
  content = "${file("${path.module}/systemd/healthzmaster.service")}"
}
