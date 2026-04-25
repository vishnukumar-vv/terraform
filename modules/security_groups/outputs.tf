output "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = aws_security_group.ec2.id
}

output "ec2_security_group_name" {
  description = "Security group name for EC2 instances"
  value       = aws_security_group.ec2.name
}

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = try(aws_security_group.alb[0].id, null)
}

output "alb_security_group_name" {
  description = "Security group name for Application Load Balancer"
  value       = try(aws_security_group.alb[0].name, null)
}

output "database_security_group_id" {
  description = "Security group ID for database"
  value       = try(aws_security_group.database[0].id, null)
}

output "database_security_group_name" {
  description = "Security group name for database"
  value       = try(aws_security_group.database[0].name, null)
}

output "cache_security_group_id" {
  description = "Security group ID for cache (Redis/ElastiCache)"
  value       = try(aws_security_group.cache[0].id, null)
}

output "cache_security_group_name" {
  description = "Security group name for cache"
  value       = try(aws_security_group.cache[0].name, null)
}

output "all_security_groups" {
  description = "All created security group IDs"
  value = {
    ec2      = aws_security_group.ec2.id
    alb      = try(aws_security_group.alb[0].id, null)
    database = try(aws_security_group.database[0].id, null)
    cache    = try(aws_security_group.cache[0].id, null)
  }
}
