data "ignition_config" "master" {
  systemd = [
    "${data.ignition_systemd_unit.apiserver.id}",
    "${data.ignition_systemd_unit.controllermanager.id}",
  ]

  files = [
    "${var.ignition_files["ca_pem"]}",
    "${var.ignition_files["svcaccount_pem"]}",
    "${var.ignition_files["svcaccount_key_pem"]}",
    "${var.ignition_files["apiserver_pem"]}",
    "${var.ignition_files["apiserver_key_pem"]}",
    "${var.ignition_files["kubelet_pem"]}",
    "${var.ignition_files["kubelet_key_pem"]}",
  ]
}

data "ignition_systemd_unit" "apiserver" {
  name   = "apiserver.service"
  enable = true

  content = <<EOF
[Unit]
Description=APIServer
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill kubernetes.apiserver || exit 0
ExecStartPre=-/usr/bin/docker rm kubernetes.apiserver || exit 0
ExecStart=
ExecStart=/usr/bin/docker run --name=kubernetes.apiserver -v /etc/kubernetes:/etc/kubernetes --net=host \
  ${var.hyperkube_image} \
  /hyperkube \
  apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --bind-address=0.0.0.0 \
  --secure-port=443 \
  --insecure-port=80 \
  --insecure-bind-address=127.0.0.1 \
  --etcd-servers=${join(",", var.etcd_nodes)} \
  --client-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-key-file=/etc/kubernetes/secrets/svcaccount-key.pem \
  --kubelet-certificate-authority=/etc/kubernetes/secrets/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/secrets/kubelet.pem \
  --kubelet-client-key=/etc/kubernetes/secrets/kubelet-key.pem \
  --tls-ca-file=/etc/kubernetes/secrets/ca.pem \
  --tls-cert-file=/etc/kubernetes/secrets/apiserver.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/apiserver-key.pem \
  --service-cluster-ip-range=${var.service_cluster_ip_range}

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "controllermanager" {
  name   = "controllermanager.service"
  enable = true

  content = <<EOF
[Unit]
Description=ControllerManager
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill kubernetes.controllermanager || exit 0
ExecStartPre=-/usr/bin/docker rm kubernetes.controllermanager || exit 0
ExecStart=
ExecStart=/usr/bin/docker run --name=kubernetes.controllermanager -v /etc/kubernetes:/etc/kubernetes --net=host \
  ${var.hyperkube_image} \
  /hyperkube \
  controller-manager \
  --address=0.0.0.0 \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --master=http://127.0.0.1:80 \
  --root-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/secrets/svcaccount-key.pem \
  --allocate-node-cidrs=true \
  --cluster-cidr=${var.cluster_cidr} \
  --service-cluster-ip-range=${var.service_cluster_ip_range}

[Install]
WantedBy=multi-user.target
EOF
}
