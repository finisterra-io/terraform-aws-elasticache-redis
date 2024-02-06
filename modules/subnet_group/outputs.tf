output "id" {
  value       = var.enabled ? aws_elasticache_subnet_group.default[0].id : null
  description = "Subnet Group ID"
}
