# redis_endpoint
# redis_port

# output "redis_endpoint" {
#     value = aws_elasticache_cluster.pte_dev_redis.endpoint
  
# }

output "port" {
    value = aws_elasticache_cluster.pte_dev_redis.port
  
}