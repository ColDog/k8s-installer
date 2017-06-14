provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "state.coldog.xyz"
    key    = "vault.tfstate"
    region = "us-west-2"
  }
}

module "vault" {
  source = "../../vault"

  bucket      = "vault.coldog.xyz"
  dns_zone_id = "Z3FHNMGH8LFH0Q"
  domain      = "coldog.xyz"
  dns_name    = "vault"
}
