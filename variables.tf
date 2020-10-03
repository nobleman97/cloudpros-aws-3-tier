variable "name_prefix" {
  type        = string
  description = "The VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC cidr"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The public subnet cidr"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The private subnet cidr"
}
