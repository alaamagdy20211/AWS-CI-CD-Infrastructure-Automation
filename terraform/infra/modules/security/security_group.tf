resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  vpc_id = var.vpc_id

  tags = {
    Name = "allow_traffic"
  }
}