variable "cluster_name" {}

resource "null_resource" "vault" {
  triggers {
    cluster_name = "${var.cluster_name}"
  }

  provisioner "local-exec" {
    command = "${path.module}/bootstrap.sh ${var.cluster_name}"
  }
}
