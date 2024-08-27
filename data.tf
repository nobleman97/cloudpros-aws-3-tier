data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "rds_pwd" {
  name = "/david/cloudpros/rds_pwd"
}

data "aws_ssm_parameter" "rds_username" {
  name = "/david/cloudpros/username"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}

data "aws_route53_zone" "main" {
  name = "shakazu.com"  
}
