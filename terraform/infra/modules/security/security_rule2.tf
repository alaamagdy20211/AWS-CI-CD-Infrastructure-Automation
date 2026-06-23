resource "aws_vpc_security_group_ingress_rule" "allow_ssh_specifiedips" {
  security_group_id = aws_security_group.allow_traffic_limited.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}