data "aws_s3_bucket" "this" {
  bucket = var.log_bucket_name
}