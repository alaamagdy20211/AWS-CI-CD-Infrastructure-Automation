resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnets["public_subnet_2"].id

  depends_on = [
    aws_internet_gateway.gw
  ]

  tags = {
    Name = "nat-gateway"
  }
}

