output "id" {
  value       = join("", aws_elasticache_replication_group.default[*].id)
  description = "Redis cluster ID"
}

output "port" {
  value       = var.port
  description = "Redis port"
}

output "reader_endpoint_address" {
  value       = join("", compact(aws_elasticache_replication_group.default[*].reader_endpoint_address))
  description = "The address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
}

output "member_clusters" {
  value       = aws_elasticache_replication_group.default[*].member_clusters
  description = "Redis cluster members"
}

output "arn" {
  value       = join("", aws_elasticache_replication_group.default[*].arn)
  description = "Elasticache Replication Group ARN"
}

output "engine_version_actual" {
  value       = join("", aws_elasticache_replication_group.default[*].engine_version_actual)
  description = "The running version of the cache engine"
}

output "cluster_enabled" {
  value       = join("", aws_elasticache_replication_group.default[*].cluster_enabled)
  description = "Indicates if cluster mode is enabled"
}
