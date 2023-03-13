resource "aws_lb" "alb" {
  count                      = var.type == "application" ? 1 : 0
  name                       = format("%s-%s-%s", var.appname, var.env, "application")
  internal                   = var.internal
  load_balancer_type         = var.type
  security_groups            = ["sg-0fb298b540c701a7b"]
  subnets                    = ["subnet-066bb6df6928434a0", "subnet-00618814f1211b581"]
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
  subnets                    = ["subnet-066bb6df6928434a0", "subnet-00618814f1211b581"]
  enable_deletion_protection = false
  tags                       = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "NLB") })
}

resource "aws_s3_bucket" "log-bucket" {
  bucket = "logbucket-${var.appname}-${var.env}-${random_string.random.id}"
}
resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.log-bucket.id
  policy = data.aws_iam_policy_document.policy.json
}
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log-bucket.id}/${var.appname}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log-bucket.id}/${var.appname}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.log-bucket.id}"]
    actions   = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}