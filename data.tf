data "aws_canonical_user_id" "current" {}

data "aws_iam_policy_document" "combined" {
  count = var.create_bucket && local.attach_policy ? 1 : 0

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

