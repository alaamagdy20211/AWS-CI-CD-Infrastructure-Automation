resource "aws_subnet" "subnets" {
  for_each = {
    for subnet in var.subnets :
    subnet.name => subnet
  }
  vpc_id     = aws_vpc.vpc_lab1.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.type=="public" ? true : false
  tags = {
    Name =  each.value.name
    type= each.value.type
  }
}