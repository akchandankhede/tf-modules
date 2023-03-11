resource "aws_lb" "alb" {
  count                      = var.type == "application" ? 1 : 0
  name                       = format("%s-%s-%s", var.appname, var.env, "application")
  internal                   = var.internal
  load_balancer_type         = var.type
  security_groups            = ["sg-0fb298b540c701a7b"]
  subnets                    = ["subnet-066bb6df6928434a0" , "subnet-00618814f1211b581"]
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.log-bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "ALB") })
}

resource "aws_lb" "nlb" {
  count                      = var.type == "network" ? 1 : 0
  name                       = format("%s-%s-%s", var.appname, var.env, "network")
  internal                   = var.internal
  load_balancer_type         = var.type
  subnets                    = ["subnet-066bb6df6928434a0" , "subnet-00618814f1211b581"]
  enable_deletion_protection = false
  tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "NLB") })
}

resource "aws_s3_bucket" "log-bucket" {
  bucket = "logbucket-${var.appname}-${var.env}-${random_string.random.id}"
}
resource "random_string" "random" {
  length           = 5
  special          = false
  upper = false
}