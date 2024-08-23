locals {

  ######  Subnets  #####
  public_subnets = [
    for subnet in module.network.public_subnets :
    subnet.id
  ]

  app_subnets = [
    for subnet in module.network.private_subnets :
    subnet.id if can(regex(".*-priv_sub-1$", subnet.tags.Name))
  ]

  db_subnets = [
    for subnet in module.network.private_subnets :
    subnet.id if can(regex(".*-priv_sub-2$", subnet.tags.Name))
  ]

  ##### Load Balancer  ####
  albs = flatten([
    for alb in var.albs : {
      name = alb.name
      type = alb.load_balancer_type
    }
  ])

  alb_listeners = flatten([
    for alb in var.albs : [
      for target_group in alb.target_groups : [
        for listener in target_group.listeners : {
          key      = "${alb.name}_${target_group.name}_${listener.id}"
          port     = listener.port
          protocol = listener.protocol
          # target_group_tag = listener.target_group_tag
          target_group_arn = aws_lb_target_group.this["${alb.name}_${target_group.name}"].arn

          load_balancer_arn = aws_lb.this[alb.name].arn
        }
      ]
    ]
  ])

  alb_listener_rules = flatten([
    for alb_target_group in local.alb_target_groups : [
      for listener in alb_target_group.listeners : [
        for rule in listener.rules : {
          key              = "${alb_target_group.key}_${listener.id}_${rule.priority}_rule"
          priority         = rule.priority
          path_pattern     = rule.path_pattern
          listener_arn     = aws_lb_listener.this["${alb_target_group.key}_${listener.id}"].arn
          target_group_arn = aws_lb_target_group.this["${alb_target_group.key}"].arn
        }
      ]
    ]
  ])

  alb_target_groups = flatten([
    for alb in var.albs : [
      for target_group in alb.target_groups : {
        key          = "${alb.name}_${target_group.name}"
        name         = target_group.name
        port         = target_group.port
        protocol     = target_group.protocol
        listeners    = target_group.listeners
        health_check = target_group.health_check
      }
    ]
  ])


  ############################
  # Auto-scaling Configs
  ############################
  auto_scaling_groups = flatten([
    for alb in var.albs : [
      for auto_scaling_group in alb.auto_scaling_groups : {
        key                       = "${alb.name}_asg"
        desired_capacity          = auto_scaling_group.desired_capacity
        max_size                  = auto_scaling_group.max_size
        min_size                  = auto_scaling_group.min_size
        health_check_type         = auto_scaling_group.health_check_type
        health_check_grace_period = auto_scaling_group.health_check_grace_period
        launch_template_id        = "${alb.name}_asg_${auto_scaling_group.launch_templates[0].name_prefix}"
        target_group_id           = "${alb.name}_${auto_scaling_group.target_group_name}"

        launch_templates = auto_scaling_group.launch_templates
        tags             = auto_scaling_group.tags
      }

    ]
  ])

  asg_launch_templates = flatten([
    for auto_scaling_group in local.auto_scaling_groups : [
      for launch_template in auto_scaling_group.launch_templates : {
        key                         = "${auto_scaling_group.key}_${launch_template.name_prefix}"
        name_prefix                 = launch_template.name_prefix
        image_id                    = launch_template.image_id
        instance_type               = launch_template.instance_type
        associate_public_ip_address = launch_template.associate_public_ip_address
        auto_scaling_policies       = launch_template.auto_scaling_policies
        auto_scaling_group_key      = auto_scaling_group.key
      }
    ]
  ])

  auto_scaling_policies = flatten([
    for asg_launch_template in local.asg_launch_templates : [
      for auto_scaling_policy in asg_launch_template.auto_scaling_policies : {
        key                    = "${asg_launch_template.key}_${auto_scaling_policy.name}"
        name                   = auto_scaling_policy.name
        scaling_adjustment     = auto_scaling_policy.scaling_adjustment
        adjustment_type        = auto_scaling_policy.adjustment_type
        cooldown               = auto_scaling_policy.cooldown
        auto_scaling_group_key = asg_launch_template.auto_scaling_group_key
      }
    ]
  ])

  asg_keys = [
    for auto_scaling_group in local.auto_scaling_groups:
    auto_scaling_group.key
  ]

  aws_autoscaling_policy_keys = [
    for auto_scaling_policy in local.auto_scaling_policies:
    auto_scaling_policy.key  
  ]

  
}



output "aws_autoscaling_policy_keys" {
  value = local.aws_autoscaling_policy_keys
}

output "security_groups" {
  value = [
    for sg in module.security_group:
    sg.security_groups.id
    
  ]
}