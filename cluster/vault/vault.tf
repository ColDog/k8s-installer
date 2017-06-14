variable "cluster_name" {}

data "aws_caller_identity" "current" {}

resource "null_resource" "vault" {
  triggers {
    cluster_name = "${var.cluster_name}"
    checksum = "${sha512(file("${path.module}/bootstrap.sh"))}"
  }

  provisioner "local-exec" {
    command = "${path.module}/bootstrap.sh ${var.cluster_name} ${data.aws_caller_identity.current.account_id}"
  }
}
