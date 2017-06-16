data "null_data_source" "asset_url" {

}

resource "aws_s3_bucket_object" "master_remote" {
  bucket = "${var.asset_bucket}"
  key    = "${var.cluster_name}_master_${md5(data.ignition_config.master.rendered)}.json"
}

data "ignition_config" "master_remote" {
  replace {
    source = "https://${var.asset_bucket}.s3.amazonaws.com/${aws_s3_bucket_object.master_remote.key}"
    verification = "sha512-${sha512(aws_s3_bucket_object.master_remote.content)}"
  }
}

resource "aws_s3_bucket_object" "worker_remote" {
  bucket = "${var.asset_bucket}"
  key    = "${var.cluster_name}_worker_${md5(data.ignition_config.worker.rendered)}.json"
}

data "ignition_config" "worker_remote" {
  replace {
    source = "https://${var.asset_bucket}.s3.amazonaws.com/${aws_s3_bucket_object.worker_remote.key}"
    verification = "sha512-${sha512(aws_s3_bucket_object.worker_remote.content)}"
  }
}
