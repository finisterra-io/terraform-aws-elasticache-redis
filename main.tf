locals {

  # if !cluster, then node_count = replica cluster_size, if cluster then node_count = shard*(replica + 1)
  # Why doing this 'The "count" value depends on resource attributes that cannot be determined until apply'. So pre-calculating
  member_clusters_count = (var.cluster_mode_enabled
    ?
    (var.cluster_mode_num_node_groups * (var.cluster_mode_replicas_per_node_group + 1))
    :
    var.cluster_size
  )

}

resource "aws_elasticache_replication_group" "default" {
  count = var.enabled ? 1 : 0

  auth_token                  = var.transit_encryption_enabled ? var.auth_token : null
  replication_group_id        = var.replication_group_id
  description                 = var.description
  node_type                   = var.instance_type
  num_cache_clusters          = var.num_cache_clusters
  port                        = var.port
  parameter_group_name        = var.parameter_group_name
  preferred_cache_cluster_azs = var.preferred_cache_cluster_azs
  automatic_failover_enabled  = var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  subnet_group_name           = var.subnet_group_name
  security_group_ids          = [for sg_id in var.security_group_ids : sg_id == "default" ? data.aws_security_group.default[0].id : sg_id]
  maintenance_window          = var.maintenance_window
  notification_topic_arn      = var.notification_topic_arn
  engine_version              = var.engine_version
  at_rest_encryption_enabled  = var.at_rest_encryption_enabled
  transit_encryption_enabled  = var.transit_encryption_enabled || var.auth_token != null
  kms_key_id                  = var.at_rest_encryption_enabled ? var.kms_key_id : null
  snapshot_name               = var.snapshot_name
  snapshot_arns               = var.snapshot_arns
  snapshot_window             = var.snapshot_window
  snapshot_retention_limit    = var.snapshot_retention_limit
  final_snapshot_identifier   = var.final_snapshot_identifier
  data_tiering_enabled        = var.data_tiering_enabled
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = lookup(log_delivery_configuration.value, "destination", null)
      destination_type = lookup(log_delivery_configuration.value, "destination_type", null)
      log_format       = lookup(log_delivery_configuration.value, "log_format", null)
      log_type         = lookup(log_delivery_configuration.value, "log_type", null)
    }
  }

  tags = var.tags

  num_node_groups         = var.cluster_mode_enabled ? var.cluster_mode_num_node_groups : null
  replicas_per_node_group = var.cluster_mode_enabled ? var.cluster_mode_replicas_per_node_group : null
  user_group_ids          = var.user_group_ids

  lifecycle {
    ignore_changes = [
      security_group_names
    ]
  }
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = var.enabled && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)}-cpu-utilization"
  alarm_description   = "Redis cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = var.enabled && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)}-freeable-memory"
  alarm_description   = "Redis cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = element(tolist(aws_elasticache_replication_group.default[0].member_clusters), count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = var.tags
}
