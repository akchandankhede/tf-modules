provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

module "vpc" {
  source             = "../../module/vpc"
  env                = "dev"
  appname            = "pfmweb"
  vpc_cidr_block     = "192.168.0.0/16"
  public_cidr_block  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_cidr_block = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tags = {
    Owner = "dev-team"
  }
}