data "ignition_config" "vault" {
  systemd = [
    "${data.ignition_systemd_unit.vault.id}",
  ]

  files = [
    "${data.ignition_file.vault_config.id}",
  ]
}

data "ignition_systemd_unit" "vault" {
  name   = "vault.service"
  enable = true

  content = <<EOF
[Unit]
Description=Vault
Documentation=https://www.vaultproject.io
After=docker.service
Requires=docker.service

[Service]
ExexStartPre=-/usr/bin/docker stop vault.service
ExexStartPre=-/usr/bin/docker rm vault.service
ExecStart=/usr/bin/docker run \
  --name=vault.service \
  -v /etc/vault/:/etc/vault \
  -p 80:80 \
  ${var.container_image} \
  vault server -config=/etc/vault/config.hcl
ExecStop=/usr/bin/docker stop vault.service
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_file" "vault_config" {
  filesystem = "root"
  path       = "/etc/vault/config.hcl"
  mode       = 0600

  content {
    content = <<EOF
storage "s3" {
  bucket = "${var.bucket}"
}

listener "tcp" {
  address     = "0.0.0.0:80"
  tls_disable = 1
}
EOF
  }
}
