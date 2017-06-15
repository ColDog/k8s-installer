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

  bucket   = "vault.coldog.xyz"
  domain   = "coldog.xyz"
  dns_name = "vault"

  instance_type = "t2.micro"
  instances = 1
  container_image = "vault:lates"
}
