resource "aws_lb" "alb" {
  name               = "lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in [var.var.subnets[public_subnet_1] , var.var.subnets[public_subnet_2]] : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}




