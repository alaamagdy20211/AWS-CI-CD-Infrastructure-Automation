resource "aws_security_group" "allow_traffic_limited" {
  name        = "allow_traffic"
  vpc_id = module.network.vpc_id

  tags = {
    Name = "allow_traffic_limited"
  }
}