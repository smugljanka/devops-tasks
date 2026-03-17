#Public networking
resource "aws_subnet" "pub_lb_sn" {

  for_each = {
    for idx, val in local.pub_lb_cidrs : val => idx
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "${var.project}-${var.env}-pub-lb-sn-az${each.value + 1}"
  }
}

resource "aws_route_table" "pub_lb_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project}-${var.env}-pub-lb-rt"
  }
}

resource "aws_route_table_association" "pub_lb" {

  for_each = {
    for idx, val in local.pub_lb_cidrs : val => idx
  }

  subnet_id      = aws_subnet.pub_lb_sn[each.key].id
  route_table_id = aws_route_table.pub_lb_rt.id
}

### Private networking
resource "aws_subnet" "pri_fe_sn" {

  for_each = {
    for idx, val in local.pri_fe_cidrs : val => idx
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "${var.project}-${var.env}-pri-fe-sn-az${each.value + 1}"
  }
}

resource "aws_subnet" "pri_be_sn" {

  for_each = {
    for idx, val in local.pri_be_cidrs : val => idx
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "${var.project}-${var.env}-pri-be-sn-az${each.value + 1}"
  }
}

resource "aws_subnet" "pri_db_sn" {

  for_each = {
    for idx, val in local.pri_db_cidrs : val => idx
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[each.value]

  tags = {
    Name = "${var.project}-${var.env}-pri-db-sn-az${each.value + 1}"
  }
}

resource "aws_route_table" "pri_fe_rt" {

  for_each = {
    for idx, val in local.pri_fe_cidrs : val => idx
  }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[each.value].id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project}-${var.env}-pri-fe-rt-az${each.value + 1}"
  }

  depends_on = [aws_nat_gateway.main]
}

resource "aws_route_table_association" "pri_fe_sn" {

  for_each = {
    for idx, val in local.pri_fe_cidrs : val => idx
  }

  subnet_id      = aws_subnet.pri_fe_sn[each.key].id
  route_table_id = aws_route_table.pri_fe_rt[each.key].id
}

resource "aws_route_table" "pri_be_rt" {

  for_each = {
    for idx, val in local.pri_be_cidrs : val => idx
  }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[each.value].id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project}-${var.env}-pri-be-rt-az${each.value + 1}"
  }

  depends_on = [aws_nat_gateway.main]
}

resource "aws_route_table_association" "pri_be_sn" {

  for_each = {
    for idx, val in local.pri_be_cidrs : val => idx
  }

  subnet_id      = aws_subnet.pri_be_sn[each.key].id
  route_table_id = aws_route_table.pri_be_rt[each.key].id
}

resource "aws_route_table" "pri_db_rt" {
  for_each = {
    for idx, val in local.pri_db_cidrs : val => idx
  }
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[each.value].id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.project}-${var.env}-pri-db-rt-az${each.value + 1}"
  }

  depends_on = [aws_nat_gateway.main]
}

resource "aws_route_table_association" "pri_db_sn" {

  for_each = {
    for idx, val in local.pri_db_cidrs : val => idx
  }

  subnet_id      = aws_subnet.pri_db_sn[each.key].id
  route_table_id = aws_route_table.pri_db_rt[each.key].id
}