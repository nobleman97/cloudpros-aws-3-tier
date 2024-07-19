terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.58.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.63.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.9.1"
    }
  }
}
