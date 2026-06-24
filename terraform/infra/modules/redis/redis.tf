
resource "aws_elasticache_subnet_group" "subnets" {
  name       = "my-cache-subnet"
  subnet_ids = var.subnet_ids
  
}

resource "aws_elasticache_cluster" "pte_dev_redis" {
  cluster_id           = "pte-dev"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  apply_immediately    = true
  port                 = 6379
  security_group_ids       = [aws_security_group.redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.subnets.name
  
}
