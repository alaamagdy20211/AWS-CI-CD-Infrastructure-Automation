resource "aws_vpc_security_group_ingress_rule" "allow_ssh_anywheree" {
  security_group_id = aws_security_group.allow_trafficc.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
