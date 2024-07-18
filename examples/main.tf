module "s3_bucket" {
  source = "../"

  bucket_name = "CLOUD-288-AWS-S3-Module"
  # expected_bucket_owner = "590183840478"

  versioning = {
    "enabled" = true
    #   "mfa_delete" = true
  }

  # Attach Policies
  attach_policy                          = true
  attach_deny_unencrypted_object_uploads = true

  # lifecycle_rule = [

  # ]

  # Server-side Encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = null
      }
    }
  }

  # logging = {
  #   target_bucket = "perizer-vpclogsbucket"
  #   target_object_key_format = {

  #   }
  # }

}
