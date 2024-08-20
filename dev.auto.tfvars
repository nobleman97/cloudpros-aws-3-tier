name_prefix             = "cloudpros"
log_bucket_name         = "s3-access-logs-dev-1"
vpc_cidr                = "10.0.0.0/16"
enable_internet_gateway = true

vpc_subnets = {
  "AZ-1-pub_sub-1" = {
    cidr_block        = "10.0.10.0/24"
    availability_zone = "us-east-1a"
    routes = [
      {
        name                   = "AZ-1-pub_sub-1-to-internet"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated"
      }
    ]
    map_public_ip_on_launch = true
    is_private              = false
  }

  "AZ-1-priv_sub-1" = {
    cidr_block              = "10.0.20.0/24"
    availability_zone       = "us-east-1a"
    enable_nat              = true
    is_private              = true
    map_public_ip_on_launch = false
    nat_public_subnet_key   = "AZ-1-pub_sub-1"
    routes = [
      {
        name                   = "AZ-1-priv_sub-1-to-NAT"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated"
      }
    ]
  }

  "AZ-1-priv_sub-2" = {
    cidr_block              = "10.0.30.0/24"
    availability_zone       = "us-east-1a"
    enable_nat              = false
    shared_route_table_ref  = "AZ-1-priv_sub-1"
    is_private              = true
    map_public_ip_on_launch = false
    nat_public_subnet_key   = "AZ-1-pub_sub-1"
    routes = [
      {
        name                   = "AZ-1-priv_sub-2-to-NAT"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated"
      }
    ]
  }

  # ---       ---

  "AZ-2-pub_sub-1" = {
    cidr_block              = "10.0.40.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
    is_private              = false
    routes = [
      {
        name                   = "AZ-2-pub_sub-1-to-internet"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated2"
      }
    ]
  }

  "AZ-2-priv_sub-1" = {
    cidr_block              = "10.0.50.0/24"
    availability_zone       = "us-east-1b"
    enable_nat              = true
    is_private              = true
    map_public_ip_on_launch = false
    nat_public_subnet_key   = "AZ-2-pub_sub-1"
    routes = [
      {
        name                   = "AZ-2-priv_sub-1-to-NAT"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated"
      }
    ]
  }

  "AZ-2-priv_sub-2" = {
    cidr_block              = "10.0.60.0/24"
    availability_zone       = "us-east-1b"
    enable_nat              = false
    shared_route_table_ref  = "AZ-2-priv_sub-1"
    is_private              = true
    map_public_ip_on_launch = false
    nat_public_subnet_key   = "AZ-1-pub_sub-1"
    routes = [
      {
        name                   = "AZ-2-priv_sub-2-to-NAT"
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "activated"
      }
    ]
  }
}

security_groups = {
  "alb-sg" = {
    sg_name        = "alb-sg"
    sg_description = "Security group for Application Load Balancer"

    security_group_rules = {
      "alb_http" = {
        type        = "ingress"
        from_port   = 80
        to_port     = 80
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

  "app_sg" = {
    sg_name        = "app-sg"
    sg_description = "Security group for App Instances"

    security_group_rules = {
      "alb_http" = {
        type                     = "ingress"
        from_port                = 80
        to_port                  = 80
        protocol                 = "tcp"
        source_security_group_id = ["alb-sg"]
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

albs = [
  {
    name                = "app-alb"
    internal            = false
    load_balancer_type  = "application"
    security_group_tags = ["alb-sg"]

    target_groups = [
      {
        name     = "app"
        port     = 80
        protocol = "HTTP"
        health_check = {
          path                = "/"
          interval            = 30
          timeout             = 5
          healthy_threshold   = 5
          unhealthy_threshold = 2
        }

        listeners = [
          {
            id               = "http"
            port             = 80
            protocol         = "HTTP"
            rules = [{
              path_pattern = "/*"
              priority = 1
            }]
          }
        ]
      }
    ]
  }
]
