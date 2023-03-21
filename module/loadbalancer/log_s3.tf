resource "aws_s3_bucket" "log-bucket" {
  bucket = "logbucket-${var.appname}-${var.env}-${random_string.random.id}"
   force_destroy = true

        acl    = "private"

        versioning {
            enabled = true
        }
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