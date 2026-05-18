resource "aws_security_group" "allow_trafficc" {
  name        = "allow_trafficc"
vpc_id = module.network.vpc_id

  tags = {
    Name = "allow_trafficc"
  }
}