module "network" {
  source = "./modules/vpc"

  log_bucket_name         = var.log_bucket_name
  name_prefix             = var.name_prefix
  enable_internet_gateway = var.enable_internet_gateway
  vpc_cidr                = var.vpc_cidr

  subnets = var.vpc_subnets
}

#####################
# Security Group
#####################
module "security_group" {
  source = "./modules/security_groups"

  for_each = var.security_groups

  sg_name              = each.value.sg_name
  sg_description       = each.value.sg_description
  vpc_id               = module.network.vpc.id
  security_group_rules = each.value.security_group_rules
}

# Security Group for EC2 Instances
resource "aws_security_group" "app_sg" {
  vpc_id = module.network.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.security_group["alb-sg"].security_groups.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = module.network.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


######################
# Load Balancer
######################

# Application Load Balancer
resource "aws_lb" "this" {
  for_each = {
    for alb in local.albs :
    alb.name => alb
  }

  name               = each.value.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_group["alb-sg"].security_groups.id]
  subnets            = local.public_subnets
}

# Target Group
resource "aws_lb_target_group" "this" {
  for_each = {
    for target_group in local.alb_target_groups :
    target_group.key => target_group
  }

  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = module.network.vpc.id

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []

    content {
      path                = health_check.value.path
      interval            = health_check.value.interval
      timeout             = health_check.value.timeout
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }
}

# Listener for ALB
resource "aws_lb_listener" "this" {
  for_each = {
    for alb_listener in local.alb_listeners :
    alb_listener.key => alb_listener
  }

  load_balancer_arn = each.value.load_balancer_arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = {
    for alb_listener_rule in local.alb_listener_rules :
    alb_listener_rule.key => alb_listener_rule
  }

  listener_arn = each.value.listener_arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = each.value.target_group_arn
  }

  condition {

    path_pattern {
      values = [each.value.path_pattern]
    }
  }
}


# ##########################
# # Auto-scaling Groups
# ##########################

# Launch Template
resource "aws_launch_template" "this" {
  for_each = {
    for asg_launch_template in local.asg_launch_templates :
    asg_launch_template.key => asg_launch_template
  }
  name_prefix   = each.value.name_prefix
  image_id      = each.value.image_id
  instance_type = each.value.instance_type

  network_interfaces {
    associate_public_ip_address = each.value.associate_public_ip_address
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx
              # Add app code here
              EOF
}

# Auto Scaling Group
resource "aws_autoscaling_group" "this" {
  for_each = {
    for auto_scaling_group in local.auto_scaling_groups :
    auto_scaling_group.key => auto_scaling_group
  }

  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  min_size            = each.value.min_size
  vpc_zone_identifier = local.app_subnets

  launch_template {
    id      = aws_launch_template.this[each.value.launch_template_id].id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.this[each.value.target_group_id].arn]
  health_check_type         = each.value.health_check_type
  health_check_grace_period = each.value.health_check_grace_period

  tag {
    key                 = each.value.tags["key"]
    value               = each.value.tags["value"]
    propagate_at_launch = each.value.tags["propagate_at_launch"]
  }
}

# # Attach Scaling Policies
resource "aws_autoscaling_policy" "this" {
  for_each = {
    for auto_scaling_policy in local.auto_scaling_policies :
    auto_scaling_policy.key => auto_scaling_policy
  }

  name                   = each.value.name
  scaling_adjustment     = each.value.scaling_adjustment
  adjustment_type        = each.value.adjustment_type
  cooldown               = each.value.cooldown
  autoscaling_group_name = aws_autoscaling_group.this[each.value.auto_scaling_group_key].name
}


# ############################
# # RDS DB
# ############################

# # RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = var.rds_config.subnet_group_name
  subnet_ids = local.db_subnets
}

# # RDS Instance
resource "aws_db_instance" "this" {

  allocated_storage      = var.rds_config.allocated_storage
  engine                 = var.rds_config.engine
  engine_version         = var.rds_config.engine_version
  instance_class         = var.rds_config.instance_class
  db_name                = var.rds_config.db_name
  multi_az               = var.rds_config.multi_az
  skip_final_snapshot    = var.rds_config.skip_final_snapshot

  username               = data.aws_ssm_parameter.rds_username.value
  password               = data.aws_ssm_parameter.rds_pwd.value

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

##########################
# Cloud Watch
##########################

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.cloud_watch_alarms

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this[local.asg_keys[0]].name
  }

  alarm_actions = [aws_autoscaling_policy.this[local.aws_autoscaling_policy_keys[each.value.scaling_policy_id]].arn]
}






