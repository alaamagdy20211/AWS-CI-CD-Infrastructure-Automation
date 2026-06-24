resource "aws_db_subnet_group" "wp_rds_subnet_groupp" {
  name       = "wp_rdss"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "WP RDS"
  }
}