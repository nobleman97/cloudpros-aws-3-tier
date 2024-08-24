variable "bucket_name" {
  description = "Name of bucket"
  type        = string
  default     = "demo"
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled."
  type        = bool
  default     = false
}

variable "object_lock_configuration" {
  description = "Map containing S3 object locking configuration."
  type = object({

    object_lock_enabled = optional(string)
    rule = optional(object({
      default_retention = object({
        days  = optional(number)
        mode  = string
        years = optional(number)
      })
    }))
    token = optional(string)
  })

  default = {}
}

variable "force_destroy" {
  description = "Boolean that indicates indicates if all objects should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any # This is unnecessary and not recommend, so overlooked on purpose
  default     = []
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "attach_public_policy" {
  description = "Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket)"
  type        = bool
  default     = true
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_access_log_delivery_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Controls if S3 bucket should require the latest version of TLS"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_unencrypted_object_uploads" {
  description = "Controls if S3 bucket should deny unencrypted object uploads policy attached."
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_kms_key_sse" {
  description = "Controls if S3 bucket policy should deny usage of incorrect KMS key SSE."
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_encryption_headers" {
  description = "Controls if S3 bucket should deny incorrect encryption headers policy attached."
  type        = bool
  default     = false
}

variable "attach_inventory_destination_policy" {
  description = "Controls if S3 bucket should have bucket inventory destination policy attached."
  type        = bool
  default     = false
}

variable "attach_analytics_destination_policy" {
  description = "Controls if S3 bucket should have bucket analytics destination policy attached."
  type        = bool
  default     = false
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."

  type = list(object({
    id      = string
    enabled = bool

    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))

    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))

    filter = optional(object({
      and = optional(object({
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
        prefix                   = optional(string)
        tags                     = optional(map(string))
      }))

      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
      prefix                   = optional(string)

      tag = optional(object({
        key   = string
        value = string
      }))

    }))

    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
    }))

    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
      storage_class             = string
    })))

    prefix = optional(string)

    transition = optional(list(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    })))
  }))

  default = [
    {
      id      = "rule-1"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },

        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_transition = []

      filter = {
        and = {
          prefix                   = "logs/"
          object_size_greater_than = 500
          object_size_less_than    = 64000
        }

        tag = {
          key   = "managed-by"
          value = "Terraform"
        }
      }
    }
  ]
}

variable "access_log_delivery_policy_source_buckets" {
  description = "(Optional) List of S3 bucket ARNs which should be allowed to deliver access logs to this bucket."
  type        = list(string)
  default     = []
}

variable "access_log_delivery_policy_source_accounts" {
  description = "(Optional) List of AWS Account IDs should be allowed to deliver access logs to this bucket."
  type        = list(string)
  default     = []
}

variable "inventory_self_source_destination" {
  description = "Whether or not the inventory source bucket is also the destination bucket."
  type        = bool
  default     = false
}

variable "analytics_self_source_destination" {
  description = "Whether or not the analytics source bucket is also the destination bucket."
  type        = bool
  default     = false
}

variable "inventory_source_bucket_arn" {
  description = "The inventory source bucket ARN."
  type        = string
  default     = null
}

variable "analytics_source_bucket_arn" {
  description = "The analytics source bucket ARN."
  type        = string
  default     = null
}

variable "inventory_source_account_id" {
  description = "The inventory source account id."
  type        = string
  default     = null
}

variable "analytics_source_account_id" {
  description = "The analytics source account id."
  type        = string
  default     = null
}

variable "allowed_kms_key_arn" {
  description = "The ARN of KMS key which should be allowed in PutObject"
  type        = string
  default     = null
}

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type = object({
    expected_bucket_owner = optional(string)
    rule = object({
      apply_server_side_encryption_by_default = optional(object({
        sse_algorithm     = string
        kms_master_key_id = optional(string)
      }))
      bucket_key_enabled = optional(bool)
    })
  })

  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

variable "analytics_configuration" {
  description = "Map containing bucket analytics configuration."
  type = map(object({
    name = string

    storage_class_analysis = optional(object({
      data_export = object({
        output_schema_version = optional(string)
        destination = object({
          s3_bucket_destination = object({
            bucket_arn        = string
            bucket_account_id = optional(string)
            format            = optional(string)
            prefix            = optional(string)
          })
        })
      })
    }))

    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))

  }))

  default = {
    first = {
      name = "first"

      filter = {
        tags = {
          analyze = "yes"
        }
      }
    }
  }
}

variable "logging" {
  description = "Map containing access logging configuration."
  type = object({
    expected_bucket_owner = optional(string)
    target_bucket         = string
    target_prefix         = string
    target_grant = optional(list(object({
      permission = string
      grantee = object({
        email_address = optional(string)
        id            = optional(string)
        type          = string
        uri           = optional(string)
      })
    })))
  })

  default = {
    target_bucket = "perizer-vpclogsbucket"
    target_prefix = "log/"
  }
}

variable "metric_configuration" {
  description = "Map containing bucket metric configuration."
  type = list(object({
    name = string
    filter = optional(object({
      access_point = optional(string)
      prefix       = optional(string)
      tags         = optional(map(string))
    }))
  }))

  default = [{
    name = "metric1"

    filter = {
      prefix = "/logs"
    }
  }, ]
}

variable "acceleration_status" {
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be 'Enabled' or 'Suspended'."
  type        = string
  default     = null
}
