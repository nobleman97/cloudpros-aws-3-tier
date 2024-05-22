variable "name_prefix" {
  type        = string
  description = "The VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC cidr"
}

variable "public_subnets" {
  description = "A list of public subnet objects"
  type = list(object({
    name = string
    cidr_block = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  description = "A list of private subnet objects"
  type = list(object({
    name = string
    cidr_block = string
    availability_zone = string
  }))
}

