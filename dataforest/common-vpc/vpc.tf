resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    "Name" = "${var.project}-${var.env}-dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-${var.env}-igw"
  }
}

resource "aws_eip" "nat_gw" {

  count = var.single_nat_gateway ? 1 : length(local.pub_lb_cidrs)

  domain = "vpc"

  tags = {
    Name = "${var.project}-${var.env}-nat-gw-az${count.index + 1}-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

#Create NAT gateway
resource "aws_nat_gateway" "main" {

  count = var.single_nat_gateway ? 1 : length(local.pub_lb_cidrs)

  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.pub_lb_sn[local.pub_lb_cidrs[count.index]].id

  tags = {
    "Name" = "${var.project}-${var.env}-nat-gw-az${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}