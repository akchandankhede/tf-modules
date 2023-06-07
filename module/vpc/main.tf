
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIATKQJPH5XJWHZKYTP"
  secret_key = "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"
}

resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  tags             = merge(var.tags, { Name = format("%s-%s-vpc", var.appname, var.env, ) })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_cidr_block)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidr_block[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.availability_zones, count.index)
  tags                    = merge(var.tags, { Name = format("%s-%s-public-%s", var.appname, var.env, element(var.availability_zones, count.index)) })
}

resource "aws_subnet" "private" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_cidr_block[count.index]
  availability_zone = element(var.availability_zones, count.index)
  tags              = merge(var.tags, { Name = format("%s-%s-private-%s", var.appname, var.env, element(var.availability_zones, count.index)) })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = format("%s-%s-igw", var.appname, var.env, ) })
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = format("%s-%s-public", var.appname, var.env, ) })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gtw.id
  }
  tags = merge(var.tags, { Name = format("%s-%s-private", var.appname, var.env, ) })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
  depends_on     = [aws_nat_gateway.nat_gtw]
}
resource "aws_eip" "eip" {
  vpc  = true
  tags = merge(var.tags, { Name = format("%s-%s-eip_nat", var.appname, var.env, ) })
}
resource "aws_nat_gateway" "nat_gtw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = format("%s-%s-nat_gtw", var.appname, var.env, ) })
}
