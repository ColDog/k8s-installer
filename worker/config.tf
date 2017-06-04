data "ignition_config" "worker" {
  systemd = [
     "${data.ignition_systemd_unit.kubelet.id}",
     "${data.ignition_systemd_unit.kube_proxy.id}",
  ]

  files = [
     "${var.ignition_files["kubelet_kubeconfig"]}",
     "${var.ignition_files["kubelet_pem"]}",
     "${var.ignition_files["kubelet_key_pem"]}",
     "${var.ignition_files["kubelet_binary"]}",
     "${var.ignition_files["kubeproxy_binary"]}",
  ]
}

data "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true

  content = <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/var/lib/kubernetes/bin/kubelet \
  --api-servers=${var.api_server} \
  --cluster-domain=${var.cluster_domain} \
  --allow-privileged=true \
  --container-runtime=docker \
  --network-plugin=kubenet \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --serialize-image-pulls=false \
  --register-node=true \
  --tls-cert-file=/etc/kubernetes/secrets/kubelet.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/kubelet-key.pem
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "kube_proxy" {
  name   = "kube-proxy.service"
  enable = true

  content = <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/var/lib/kubernetes/bin/kube-proxy \
  --cluster-cidr=${var.cluster_cidr} \
  --masquerade-all=true \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --proxy-mode=iptables \
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}
