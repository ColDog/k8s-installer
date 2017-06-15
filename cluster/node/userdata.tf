data "ignition_config" "master" {
  systemd = [
    // System
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.bootstrap_master.id}",

    // Kubernetes
    "${data.ignition_systemd_unit.controllermanager.id}",
    "${data.ignition_systemd_unit.scheduler.id}",
    "${data.ignition_systemd_unit.apiserver.id}",
  ]

  files = [
    // Option files
    "${data.ignition_file.cni_opts.id}",
    "${data.ignition_file.cluster_opts.id}",

    // Installers
    "${data.ignition_file.cni_installer.id}",
    "${data.ignition_file.flanneld_installer.id}",
    "${data.ignition_file.kubeproxy_installer.id}",
    "${data.ignition_file.kubelet_installer.id}",

    // Scripts
    "${data.ignition_file.vault_login.id}",
    "${data.ignition_file.get_certs.id}",
    "${data.ignition_file.get_kubeconfig.id}",
    "${data.ignition_file.get_servicekey.id}",

    // Bootstrap
    "${data.ignition_file.bootstrap_master.id}",
    "${data.ignition_file.bootstrap_worker.id}",
  ]
}

data "ignition_config" "worker" {
  systemd = [
    // System
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.bootstrap_worker.id}",

    // Kubernetes
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.flanneld.id}",
    "${data.ignition_systemd_unit.kubeproxy.id}",
  ]

  files = [
    // Option files
    "${data.ignition_file.cni_opts.id}",
    "${data.ignition_file.cluster_opts.id}",

    // Installers
    "${data.ignition_file.cni_installer.id}",
    "${data.ignition_file.flanneld_installer.id}",
    "${data.ignition_file.kubeproxy_installer.id}",
    "${data.ignition_file.kubelet_installer.id}",

    // Scripts
    "${data.ignition_file.vault_login.id}",
    "${data.ignition_file.get_certs.id}",
    "${data.ignition_file.get_kubeconfig.id}",
    "${data.ignition_file.get_servicekey.id}",

    // Bootstrap
    "${data.ignition_file.bootstrap_master.id}",
    "${data.ignition_file.bootstrap_worker.id}",
  ]
}
