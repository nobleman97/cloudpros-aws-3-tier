data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "rds_pwd" {
  name = "/david/cloudpros/rds_pwd"
}

data "aws_ssm_parameter" "rds_username" {
  name = "/david/cloudpros/username"
}
