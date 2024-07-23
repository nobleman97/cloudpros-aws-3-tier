module "s3_bucket" {
  source = "../../"

  bucket_name = "CLOUD-288-AWS-S3-Module"
  # expected_bucket_owner = "590183840478"



  # Attach Policies
  # attach_policy                          = true
  # attach_deny_unencrypted_object_uploads = true

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
  # server_side_encryption_configuration = {
  #   rule = {
  #     apply_server_side_encryption_by_default = {
  #       sse_algorithm     = "aws:kms"
  #       kms_master_key_id = null
  #     }
  #   }
  # }



}
