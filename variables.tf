

variable "name_prefix" {
  type        = string
  description = "The VPC name"

}

####################################
# VPC
####################################

variable "vpc_cidr" {
  type        = string
  description = "The VPC cidr"
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "Dedfault region to deploy resources to"
  type        = string
  default     = "us-east-1"
}

variable "enable_dns_support" {
  description = "Enable DNS support or not"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames or not"
  type        = bool
  default     = true
}


#####################################
#  Subnets
#####################################

variable "public_subnets" {
  description = "A list of public subnet objects"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = [{
    name                    = "public_1"
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
  }]
}

variable "private_subnets" {
  description = "A list of private subnet objects"
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))

  default = [{
    name              = "private_1"
    cidr_block        = "10.0.100.0/24"
    availability_zone = "us-east-1a"
  }]
}


variable "enable_private_subnets" {
  description = "Flag to enable or disable private subnets"
  type        = bool
  default     = false
}


variable "dynamic_subnets" {
  description = "A variable holding all subnets"
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = {
    "first" = {
      cidr_block              = "10.0.200.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true
    }

    "second" = {
      cidr_block              = "10.0.205.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
    }
  }
}

