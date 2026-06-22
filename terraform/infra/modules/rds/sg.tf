resource "aws_security_group" "rdssecuritygroup" {
  name        = "rds_security_group"
  description = "Allow inbound traffic only for MYSQL and all outbound traffic"
  vpc_id = var.vpc_id
 ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.app_sg_id]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}