variable "bucket" {}

resource "null_resource" "exec" {
  triggers {
    checksum = "${md5(file("${path.module}/push"))}"
  }
  provisioner "local-exec" {
    command = "${path.module}/push ${var.bucket}"
  }
}
