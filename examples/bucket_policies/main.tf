module "s3_bucket" {
  source = "../../"

  bucket_name = "CLOUD-288-AWS-S3-Module"

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  # Attach Policies
  attach_policy                         = true
  attach_deny_insecure_transport_policy = true

  # Add an additional policy like the one below
  policy = data.aws_iam_policy_document.allow_public_access.json

  # Enable Public Access    # Set all to `false` to allow all public access
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true

  # Note: Object Lock configuration can be enabled only on new buckets
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }

  metric_configuration = [
    {
      name = "documents"
      filter = {
        prefix = "documents/"
        tags = {
          priority = "high"
        }
      }
    },
    {
      name = "other"
      filter = {
        tags = {
          production = "true"
        }
      }
    },
    {
      name = "all"
    }
  ]

  logging = {
    target_bucket = "perizer-vpclogsbucket" #module.log_bucket.s3_bucket_id
    target_prefix = "test_s3_logging/"
    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime" # "EventTime"
      }
      # simple_prefix = {}
    }
  }
}

# WARNING: This is a public access policy. We probably don't want to use it
data "aws_iam_policy_document" "allow_public_access" {
  version = "2012-10-17"

  statement {
    sid    = "Stmt1721723434229"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes"
    ]

    resources = [
      "${module.s3_bucket.bucket.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
