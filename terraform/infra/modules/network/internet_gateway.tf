resource "aws_internet_gateway" "gw"{
    vpc_id = aws_vpc.vpc_lab1.id
    tags ={
        Name = "internet_gateway"
    }
}