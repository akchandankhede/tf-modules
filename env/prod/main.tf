provider "aws" {
    profile = "terraform"
    region = "us-east-1"
}

module "vpc" {
    source = "../../module/vpc"
    env = "production"
    vpc_cidr_block = "192.168.0.0/16"
    public_cidr_block = "192.168.1.0/24"
    private_cidr_block = "192.168.2.0/24"
    availability_zones = "us-east-1a"
}