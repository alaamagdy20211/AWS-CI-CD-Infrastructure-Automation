resource "aws_db_instance" "wp_rds" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "password123"
  vpc_security_group_ids = [aws_security_group.rdssecuritygroup.id]
  db_subnet_group_name   = "wp_rds"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  depends_on = [aws_db_subnet_group.wp_rds_subnet_groupp]
}