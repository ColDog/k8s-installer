provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "state.default.coldog.xyz"
    key    = "cluster-state"
    region = "us-west-2"
  }
}

//module "cluster" {
//  source = "./cluster"
//
//  dns_zone_id  = "Z3FHNMGH8LFH0Q"
//  base_domain  = "coldog.xyz"
//  state_bucket = "state.default.coldog.xyz"
//  cluster_name = "default"
//}
//
//output "api_server" {
//  value = "${module.cluster.api_server}"
//}

module "vault" {
  source = "./vault"

  bucket             = "vault.coldog.xyz"
  dns_zone_id        = "Z3FHNMGH8LFH0Q"
  ssl_certificate_id = "arn:aws:acm:us-east-1:414904551680:certificate/8ea61258-d7c4-4528-8255-cf478e4410e8"
}
