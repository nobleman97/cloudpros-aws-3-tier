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
            id       = "http"
            port     = 80
            protocol = "HTTP"
            rules = [{
              path_pattern = "/*"
              priority     = 1
            }]
          }
        ]
      }
    ]

    auto_scaling_groups = [{
      desired_capacity          = 2
      max_size                  = 4
      min_size                  = 1
      health_check_type         = "EC2"
      health_check_grace_period = 300
      target_group_name         = "app"
      tags = {
        key                 = "Name"
        value               = "AppInstance"
        propagate_at_launch = true
      }

      launch_templates = [{
        associate_public_ip_address = false
        auto_scaling_policies = [
          {
            adjustment_type    = "ChangeInCapacity"
            cooldown           = 300
            name               = "scale-out-1"
            scaling_adjustment = 1
          },
          {
            adjustment_type    = "ChangeInCapacity"
            cooldown           = 300
            name               = "scale-in-1"
            scaling_adjustment = -1
          }
        ]
        image_id      = "ami-04a81a99f5ec58529"
        instance_type = "t3.micro"
        name_prefix   = "app-lt-"
      }]
    }]
  }
]

rds_config = {
  subnet_group_name      = "rds-subnet-group"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "appdb"
  multi_az               = true
  skip_final_snapshot    = true
}

cloud_watch_alarms = {
  "cpu_high" = {
    alarm_name          = "cpu_high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 70
    scaling_policy_id   = 0
  }

  "cpu_low" = {
    alarm_name          = "cpu_low"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 30
    scaling_policy_id   = 1
  }
}

s3_config = {
  force_destroy = true
  acceleration_status = "Suspended"
  request_payer       = "BucketOwner"

  tags = {
    Owner = "David"
  }

  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }

  attach_policy                            = true
  attach_deny_insecure_transport_policy    = true
  attach_require_latest_tls_policy         = true
  attach_deny_incorrect_encryption_headers = true
  attach_deny_incorrect_kms_key_sse        = true
  attach_deny_unencrypted_object_uploads   = false

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status     = true
    mfa_delete = false
  }  

  lifecycle_rule = [
    {
      id                                     = "log1"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }

      filter = {
        tags = {
          Owner    = "David"
        }
      }
    },
    {
      id      = "log2"
      enabled = true

      filter = {
        prefix                   = "log1/"
        object_size_greater_than = 200000
        object_size_less_than    = 500000
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    }
  ]
}