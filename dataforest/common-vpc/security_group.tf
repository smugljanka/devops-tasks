# Lock down the default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-disabled-default-sg"
  }

  depends_on = [aws_vpc.main]
}

# Pub LB SG
resource "aws_security_group" "pub_lb" {
  name        = "${var.project}-${var.env}-pub-lb-sg"
  description = "Security group for ${var.project} public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-pub-lb-sg"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group_rule" "pub_lb_https_inbound" {
  security_group_id = aws_security_group.pub_lb.id
  description       = "Allow inbound traffic to HTTPS endpoint from anywhere"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "pub_lb_http_inbound" {
  security_group_id = aws_security_group.pub_lb.id
  description       = "Allow inbound traffic to HTTP endpoint from anywhere"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "pub_lb_outbound" {
  security_group_id = aws_security_group.pub_lb.id
  description       = "Allow outbound traffic to FE"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = local.pri_fe_cidrs
}

# Private FE SG
resource "aws_security_group" "pri_fe" {
  name        = "${var.project}-${var.env}-pri-fe-sg"
  description = "Security group for ${var.project} private FE"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-pri-fe-sg"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group_rule" "pri_fe_inbound_alb" {
  security_group_id        = aws_security_group.pri_fe.id
  description              = "Allow inbound traffic from upstream ALB"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.pub_lb.id
}

resource "aws_security_group_rule" "pri_fe_inbound_cf" {
  security_group_id        = aws_security_group.pri_fe.id
  description              = "Allow inbound traffic from Global Cloudfront"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "http"
  source_security_group_id = data.aws_prefix_list.cloudfront_global.id
}

resource "aws_security_group_rule" "pri_fe_outbound_be" {
  security_group_id = aws_security_group.pri_fe.id
  description       = "Allow outbound traffic to everywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Private BE subnets
resource "aws_security_group" "pri_be" {
  name        = "${var.project}-${var.env}-pri-be-sg"
  description = "Security group for ${var.project} private BE"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-pri-be-sg"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group_rule" "pri_be_inbound" {
  security_group_id        = aws_security_group.pri_be.id
  description              = "Allow inbound traffic from FE"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.pri_fe.id
}

resource "aws_security_group_rule" "pri_be_outbound" {
  security_group_id = aws_security_group.pri_be.id
  description       = "Allow outbound traffic to everywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Private DB subnets
resource "aws_security_group" "pri_db" {
  name        = "${var.project}-${var.env}-pri-db-sg"
  description = "Security group for ${var.project} private DB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-pri-db-sg"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_security_group_rule" "pri_db_inbound" {
  security_group_id        = aws_security_group.pri_db.id
  description              = "Allow inbound traffic from BE"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.pri_be.id
}

resource "aws_security_group_rule" "pri_db_outbound" {
  security_group_id = aws_security_group.pri_db.id
  description       = "Allow outbound traffic to everywhere"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
