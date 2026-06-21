resource "aws_db_subnet_group" "wp_rds_subnet_group" {
  name       = "wp_rds"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "WP RDS"
  }
}