provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "coldog-tfstate"
    key    = "assets.tfstate"
    region = "us-west-2"
  }
}

module "assets" {
  source = "../../assets"
  bucket = "coldog-cluster-assets"
}
