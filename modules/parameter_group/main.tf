resource "aws_elasticache_parameter_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = var.name
  description = var.description
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  tags = var.tags

  # Ignore changes to the description since it will try to recreate the resource
  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}
