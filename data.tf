data "aws_canonical_user_id" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "combined" {
  count = local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_access_log_delivery_policy ? data.aws_iam_policy_document.access_log_delivery[0].json : "",
    var.attach_require_latest_tls_policy ? data.aws_iam_policy_document.require_latest_tls[0].json : "",
    var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
    var.attach_deny_unencrypted_object_uploads ? data.aws_iam_policy_document.deny_unencrypted_object_uploads[0].json : "",
    var.attach_deny_incorrect_kms_key_sse ? data.aws_iam_policy_document.deny_incorrect_kms_key_sse[0].json : "",
    var.attach_deny_incorrect_encryption_headers ? data.aws_iam_policy_document.deny_incorrect_encryption_headers[0].json : "",
    var.attach_inventory_destination_policy || var.attach_analytics_destination_policy ? data.aws_iam_policy_document.inventory_and_analytics_destination_policy[0].json : "",
    var.attach_policy ? var.policy : ""
  ])
}

# ALB/NLB
data "aws_iam_policy_document" "lb_log_delivery" {
  count = var.attach_lb_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

# Grant access to S3 log delivery group for server access logging
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-migrating-acls-prerequisites.html#object-ownership-server-access-logs
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html#grant-log-delivery-permissions-general
data "aws_iam_policy_document" "access_log_delivery" {
  count = var.attach_access_log_delivery_policy ? 1 : 0

  statement {
    sid = "AWSAccessLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_buckets) != 0 ? [true] : []
      content {
        test     = "ForAnyValue:ArnLike"
        variable = "aws:SourceArn"
        values   = var.access_log_delivery_policy_source_buckets
      }
    }

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_accounts) != 0 ? [true] : []
      content {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:SourceAccount"
        values   = var.access_log_delivery_policy_source_accounts
      }
    }

  }

  statement {
    sid = "AWSAccessLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this.arn,
    ]

  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  count = var.attach_deny_insecure_transport_policy ? 1 : 0

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "inventory_and_analytics_destination_policy" {
  count = var.attach_inventory_destination_policy || var.attach_analytics_destination_policy ? 1 : 0

  statement {
    sid    = "destinationInventoryAndAnalyticsPolicy"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = compact(distinct([
        var.inventory_self_source_destination ? aws_s3_bucket.this.arn : var.inventory_source_bucket_arn,
        var.analytics_self_source_destination ? aws_s3_bucket.this.arn : var.analytics_source_bucket_arn
      ]))
    }

    condition {
      test = "StringEquals"
      values = compact(distinct([
        var.inventory_self_source_destination ? data.aws_caller_identity.current.id : var.inventory_source_account_id,
        var.analytics_self_source_destination ? data.aws_caller_identity.current.id : var.analytics_source_account_id
      ]))
      variable = "aws:SourceAccount"
    }

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}

data "aws_iam_policy_document" "deny_incorrect_encryption_headers" {
  count = var.attach_deny_incorrect_encryption_headers ? 1 : 0

  statement {
    sid    = "denyIncorrectEncryptionHeaders"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm, null) == "aws:kms" ? ["aws:kms"] : ["AES256"]
    }
  }
}

data "aws_iam_policy_document" "deny_incorrect_kms_key_sse" {
  count = var.attach_deny_incorrect_kms_key_sse ? 1 : 0

  statement {
    sid    = "denyIncorrectKmsKeySse"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [try(var.allowed_kms_key_arn, null)]
    }
  }
} 

data "aws_iam_policy_document" "require_latest_tls" {
  count = var.attach_require_latest_tls_policy ? 1 : 0

  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = var.attach_elb_log_delivery_policy ? 1 : 0

  # Policy for AWS Regions created before August 2022 (e.g. US East (N. Virginia), Asia Pacific (Singapore), Asia Pacific (Sydney), Asia Pacific (Tokyo), Europe (Ireland))
  dynamic "statement" {
    for_each = { for k, v in local.elb_service_accounts : k => v if k == data.aws_region.current.name }

    content {
      sid = format("ELBRegion%s", title(statement.key))

      principals {
        type        = "AWS"
        identifiers = [format("arn:%s:iam::%s:root", data.aws_partition.current.partition, statement.value)]
      }

      effect = "Allow"

      actions = [
        "s3:PutObject",
      ]

      resources = [
        "${aws_s3_bucket.this.arn}/*",
      ]
    }
  }

  # Policy for AWS Regions created after August 2022 (e.g. Asia Pacific (Hyderabad), Asia Pacific (Melbourne), Europe (Spain), Europe (Zurich), Middle East (UAE))
  statement {
    sid = ""

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "deny_unencrypted_object_uploads" {
  count = var.attach_deny_unencrypted_object_uploads ? 1 : 0

  statement {
    sid    = "denyUnencryptedObjectUploads"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }
  }
}


