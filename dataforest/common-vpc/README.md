# Setup VPC

## Setup VPC and public subnets

For testing purpose in order not to spend money on NAT+EIP

```shell
tfa -target="aws_vpc_dhcp_options_association.main" \
-target='aws_vpc_dhcp_options.main ' \
-target='aws_vpc.main' \
-target='aws_subnet.pub_lb_sn["10.100.1.0/24"]' \
-target='aws_subnet.pub_lb_sn["10.100.0.0/24"]' \
-target='aws_security_group_rule.pub_lb_outbound' \
-target='aws_security_group_rule.pub_lb_https_inbound' \
-target='aws_security_group_rule.pub_lb_http_inbound' \
-target='aws_security_group.pub_lb' \
-target='aws_route_table_association.pub_lb["10.100.1.0/24"]' \
-target='aws_route_table_association.pub_lb["10.100.0.0/24"]' \
-target='aws_route_table.pub_lb_rt' \
-target='aws_internet_gateway.main' \
-target='aws_default_security_group.default'
```