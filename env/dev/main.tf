provider "aws" {
  profile = "terraform"
  region  = "us-east-1"
}

/* module "vpc" {
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
} */

module "load-balancer" {
  source   = "../../module/loadbalancer"
  env      = "dev"
  appname  = "crypto"
  internal = "false"
  type     = "application"
  tags = {
    Owner = "dev-team"
  }
  listener_rule = {
    laptop = {
      priority         = "10"
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:571479247742:targetgroup/crypto-dev-tg/c864b5d95ee48c73"
      values           = ["/laptop/*"]
    }

    mobile = {
      priority         = "20"
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:571479247742:targetgroup/crypto-dev-tg/c864b5d95ee48c73"
      values           = ["/mobile/*"]
    }

    tv = {
      priority         = "30"
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:571479247742:targetgroup/crypto-dev-tg/c864b5d95ee48c73"
      values           = ["/tv/*"]
    }

    cloths = {
      priority         = "40"
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:571479247742:targetgroup/crypto-dev-tg/c864b5d95ee48c73"
      values           = ["/cloths/*"]
    }

    cloudblitz = {
      priority         = "50"
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:571479247742:targetgroup/crypto-dev-tg/c864b5d95ee48c73"
      values           = ["/cloudblitzs/*"]
    }

  }
} 