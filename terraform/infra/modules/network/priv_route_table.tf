resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_lab1.id

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}