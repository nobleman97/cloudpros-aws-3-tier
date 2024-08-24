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
    }
  ]

  lifecycle_rule = [

    {
      id = "rule-1"

      transition = {
        days          = 30
        storage_class = "STANDARD_IA"
      }

      transition = {
        days          = 60
        storage_class = "GLACIER"
      }

      expiration = {
        days = 90
      }

      filter = {
        and = {
          prefix                   = "logs/"
          object_size_greater_than = 500
          object_size_less_than    = 64000
        }
      }

      enabled = true
    },

    {
      id = "non-current"

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }

      noncurrent_version_transition = {
        noncurrent_days = 30
        storage_class   = "STANDARD_IA"
      }

      noncurrent_version_transition = {
        noncurrent_days = 60
        storage_class   = "GLACIER"
      }

      filter = {
        prefix = "logs/"
      }

      enabled = true
    }

  ]

  # Server-side Encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = null # The default `aws/s3` AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`.
      }
    }
  }

  logging = {
    bucket        = "CLOUD-288-AWS-S3-Module"
    target_bucket = "perizer-vpclogsbucket"
    target_prefix = "log/"


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
