data "aws_vpc" "default" {
  count = module.this.enabled && var.vpc_name != null ? 1 : 0
  tags = {
    Name = var.vpc_name
  }
}

data "aws_security_group" "default" {
  count  = var.enabled ? 1 : 0
  name   = "default"
  vpc_id = var.vpc_name != null ? data.aws_vpc.default[0].id : var.vpc_id
}
