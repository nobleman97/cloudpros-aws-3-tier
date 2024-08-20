variable "vpc_subnets" {
  description = "A map of objects of subnets configs"
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)
    is_private              = optional(bool, true)
    enable_nat              = optional(bool, false)
    nat_public_subnet_key   = optional(string, null)
    shared_route_table_ref  = optional(string, null)
    routes = optional(list(object({
      name                        = string
      destination_cidr_block      = optional(string, null)
      destination_ipv6_cidr_block = optional(string, null)
      destination_prefix_list_id  = optional(string, null)
      carrier_gateway_id          = optional(string, null)
      core_network_arn            = optional(string, null)
      egress_only_gateway_id      = optional(string, null)
      gateway_id                  = optional(string, null)
      nat_gateway_ref             = optional(string, null)
      local_gateway_id            = optional(string, null)
      network_interface_id        = optional(string, null)
      transit_gateway_id          = optional(string, null)
      vpc_endpoint_id             = optional(string, null)
      vpc_peering_connection_id   = optional(string, null)
    })), [])

  }))
}

variable "log_bucket_name" {
  description = "Name of bucket where logs will be sent"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "A name prefix for resources relate to the network"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR Range to allocate to the VPC"
  type        = string
  default     = ""
}

variable "enable_internet_gateway" {
  description = "Toggle turning on internet gateway or not"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "a map of objects for security groups"
  type = map(object({
    sg_name        = string
    sg_description = optional(string, "")
    vpc_identifier = optional(string, null)

    security_group_rules = map(object({
      type        = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string), [])
      #   source_security_group_id = optional(list(string), null)
    }))
  }))

  default = {
    "dev-alb-sg" = {
      sg_name        = "dev-alb-sg"
      sg_description = "security group for dev alb"
      vpc_identifier = "primary"

      security_group_rules = {
        "alb_http" = {
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

        "alb_https" = {
          type        = "ingress"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

        "alb_egress" = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

variable "albs" {
  type = list(object({
    name                = string
    internal            = bool
    load_balancer_type  = string
    subnet_tags         = optional(list(string))
    security_group_tags = optional(list(string))

    target_groups = list(object({
      name     = string
      port     = number
      protocol = string
      #   vpc_id   = optional(string)
      health_check = optional(object({
        path                = string
        interval            = number
        timeout             = number
        healthy_threshold   = number
        unhealthy_threshold = number
      }))

      listeners = optional(list(object({
        id               = string
        port             = number
        protocol         = string
        rules     = optional(list(object({
            priority = number
            path_pattern = string
        })))
      })))
    }))

  }))
}
  