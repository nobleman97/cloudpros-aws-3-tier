variable "sg_name" {
  type = string
}

variable "sg_description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_group_rules" {
  type = map(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
    # source_security_group_id = optional(list(string), [""])
  }))
}


# variable "tags" {
#   description = "an object of tags"
#   type = object({
#     key = string
#     value = string
#   })
# }

