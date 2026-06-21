resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_lab1.id

  tags = {
    Name = "private_route_table"
  }
}