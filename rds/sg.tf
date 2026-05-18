resource "aws_security_group" "rdssecuritygroup" {
  name        = "rds_security_group"
  description = "Allow inbound traffic only for MYSQL and all outbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "rds_security_group"
  }
}

resource "aws_vpc_security_group_egress_rule" "rds_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rdssecuritygroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "rds_allow_http_ipv4" {
  security_group_id = aws_security_group.rdssecuritygroup.id
  cidr_ipv4         =  var.vpc_cidr
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}