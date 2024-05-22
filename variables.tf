variable "region" {
  description = "Dedfault region to deploy resources to"
  type = string
  default = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "The VPC name"
  
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC cidr"
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnet objects"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))

  default = [ {
    name = "public_1"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  } ]
}

variable "private_subnets" {
  description = "A list of private subnet objects"
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))

  default = [ {
    name = "private_1"
    cidr_block = "10.0.100.0/24"
    availability_zone = "us-east-1a"
  } ]
}


variable "enable_private_subnets" {
  description = "Flag to enable or disable private subnets"
  type        = bool
  default     = false
}
