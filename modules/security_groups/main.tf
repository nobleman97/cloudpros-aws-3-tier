
resource "aws_security_group" "main" {

  name        = var.sg_name
  description = var.sg_description

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  # tags = var.tags
}

resource "aws_security_group_rule" "main" {
  for_each = var.security_group_rules

  type        = each.value.type
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  # source_security_group_id = each.value.source_security_group_id

  security_group_id = aws_security_group.main.id
}
