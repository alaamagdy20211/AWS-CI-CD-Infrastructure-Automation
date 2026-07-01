locals {
  public_subnet_ids = [
    for s in var.subnets : s.id
    if s.tags["type"] == "public"
  ]
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow incoming HTTP connections to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "application_lb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnet_ids

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "app-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/db"
    port                = "traffic-port"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "app-tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.app_id
  port             = 3000
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = var.app_sg_id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
}