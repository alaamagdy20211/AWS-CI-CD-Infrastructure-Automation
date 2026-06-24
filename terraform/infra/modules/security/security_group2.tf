resource "aws_security_group" "allow_traffic_limited" {
  name        = "allow_traffic-limited"
  vpc_id = var.vpc_id

  tags = {
    Name = "allow_traffic_limited"
  }
}