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

resource "aws_lb_listener" "http_listener" {
  count             = var.type == "application" ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

/* resource "aws_lb_listener" "https_listener" {
  count             = var.type == "application" ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = "443"
  protocol          = "TLS"target_type = ""
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  depends_on = [aws_lb_target_group.this]
} */


resource "aws_lb_listener_rule" "static" {
  count             = var.type == "application" ? 1 : 0
  listener_arn = aws_lb_listener.http_listener[0].arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    path_pattern {
      values = ["/mobile/*"]
    }
  }
}
resource "aws_lb_listener_rule" "laptop" {
  count             = var.type == "application" ? 1 : 0
  listener_arn = aws_lb_listener.http_listener[0].arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    path_pattern {
      values = ["/laptop/*"]
    }
  }
}
resource "aws_lb_target_group" "this" {
  name     = format("%s-%s-%s", var.appname, var.env, "tg")
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0722bf8a285902f28"
}