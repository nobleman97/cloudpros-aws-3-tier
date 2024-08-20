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
        for listener in target_group.listeners: {
            key              = "${alb.name}_${target_group.name}_${listener.id}"
            port             = listener.port
            protocol         = listener.protocol
            # target_group_tag = listener.target_group_tag
            target_group_arn    = aws_lb_target_group.this["${alb.name}_${target_group.name}"].arn

            load_balancer_arn   = aws_lb.this[alb.name].arn
        }
      ]
    ]
  ])

  alb_listener_rules = flatten([
    for alb_target_group in local.alb_target_groups: [
      for listener in alb_target_group.listeners: [
        for rule in listener.rules: {
            key = "${alb_target_group.key}_${listener.id}_${rule.priority}_rule"
            priority = rule.priority
            path_pattern = rule.path_pattern
            listener_arn  = aws_lb_listener.this["${alb_target_group.key}_${listener.id}"].arn
            target_group_arn = aws_lb_target_group.this["${alb_target_group.key}"].arn
        }
      ]
    ]
  ])

  alb_target_groups = flatten([ 
    for alb in var.albs : [
      for target_group in alb.target_groups : {
        key      = "${alb.name}_${target_group.name}"
        name     = target_group.name
        port     = target_group.port
        protocol = target_group.protocol
        listeners = target_group.listeners
        health_check = target_group.health_check
      }
    ]
  ])


}

