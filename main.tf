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

# # Launch Template
# resource "aws_launch_template" "app_lt" {
#   name_prefix   = "app-lt-"
#   image_id      = "ami-04a81a99f5ec58529" 
#   instance_type = "t3.micro"

#   network_interfaces {
#     associate_public_ip_address = false
#     security_groups             = [aws_security_group.app_sg.id]
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               apt update -y
#               # Add app code here
#               EOF
# }

# # Auto Scaling Group
# resource "aws_autoscaling_group" "app_asg" {
#   desired_capacity     = 4
#   max_size             = 8
#   min_size             = 2
#   vpc_zone_identifier  = local.app_subnets

#   launch_template {
#     id      = aws_launch_template.app_lt.id
#     version = "$Latest"
#   }

#   target_group_arns = [aws_lb_target_group.app_tg.arn]
#   health_check_type = "EC2"
#   health_check_grace_period = 300

#   tag {
#     key                 = "Name"
#     value               = "AppInstance"
#     propagate_at_launch = true
#   }
# }

# # Attach Scaling Policies
# resource "aws_autoscaling_policy" "scale_out" {
#   name                   = "scale-out"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.app_asg.name
# }

# resource "aws_autoscaling_policy" "scale_in" {
#   name                   = "scale-in"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.app_asg.name
# }


# ############################
# # RDS DB
# ############################

# # RDS Subnet Group
# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "rds-subnet-group"
#   subnet_ids = local.db_subnets
# }

# # RDS Instance
# resource "aws_db_instance" "app_db" {
#   allocated_storage    = 20
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   db_name              = "appdb"
#   username             = "admin"
#   password             = "insecurepassword"  # Use a secure method to store this password
#   db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
#   multi_az             = true
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   skip_final_snapshot  = true
# }

# ##########################
# # Cloud Watch
# ##########################

# resource "aws_cloudwatch_metric_alarm" "cpu_high" {
#   alarm_name          = "cpu_high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 70

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.app_asg.name
#   }

#   alarm_actions = [aws_autoscaling_policy.scale_out.arn]
# }

# resource "aws_cloudwatch_metric_alarm" "cpu_low" {
#   alarm_name          = "cpu_low"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 30

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.app_asg.name
#   }

#   alarm_actions = [aws_autoscaling_policy.scale_in.arn]
# }




