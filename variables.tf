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

# variable "public_subnet_cidr" {
#   type        = string
#   description = "The public subnet cidr"
# }

# variable "private_subnet_cidr" {
#   type        = string
#   description = "The private subnet cidr"
# }

# variable "private_2_subnet_cidr" {
#   type        = string
#   description = "The private 2 subnet cidr"
# }