# https://github.com/terraform-aws-modules/terraform-aws-alb
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  create  = var.create_alb
  name    = "${var.project}-${var.env}-pub-alb"
  vpc_id  = data.aws_vpc.main.id
  subnets = toset(data.aws_subnets.pub_lb_subnets.ids)

  # Security Group
  create_security_group = false
  security_groups       = [data.aws_security_group.pub_lb_sg.id]

  listeners = {

    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port                        = 443
      protocol                    = "HTTPS"
      certificate_arn             = var.certificate_arn
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
      additional_certificate_arns = var.additional_certificate_arns

      forward = {
        target_group_arn = try(aws_lb_target_group.fe[0].arn, null)
      }
    }
  }

  enable_tls_version_and_cipher_suite_headers = true

  # Forward original client address to upstream
  enable_xff_client_port     = true
  xff_header_processing_mode = "preserve"
  preserve_host_header       = true

  # Disable LB deletion via API
  enable_deletion_protection = true

  tags = {
    Name = "${var.project}-${var.env}-pub-alb"
  }

  depends_on = [aws_lb_target_group.fe]
}

#Target group for FE nodes
resource "aws_lb_target_group" "fe" {

  count = var.create_alb ? 1 : 0

  name     = "${var.project}-${var.env}-frontend-tg-${count.index + 1}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  deregistration_delay = 10

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  load_balancing_algorithm_type     = "weighted_random"
  load_balancing_anomaly_mitigation = "on"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"

  tags = {
    Name = "${var.project}-${var.env}-frontend-tg-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "fe" {

  for_each = (
    var.create_alb
    ? { for k, v in var.fe_instance_configs : k => v }
    : {}
  )

  target_group_arn = aws_lb_target_group.fe[0].arn
  target_id        = module.fe[each.key].id
  port             = 8080
}
