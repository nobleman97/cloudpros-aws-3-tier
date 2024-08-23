terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.5.0"
    }
  }

  backend "s3" {
    bucket         = "infra-shakazu-bucket"
    key            = "state_files/cloudpros/development.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudpros_tf_lock-dynamo-table"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
