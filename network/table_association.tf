resource "aws_route_table_association" "tab_asso"{
    subnet_id = aws_subnet.subnets["public_subnet_1"].id
    route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "tab_asso_2"{
    subnet_id = aws_subnet.subnets["public_subnet_2"].id
    route_table_id = aws_route_table.public_rt.id
}