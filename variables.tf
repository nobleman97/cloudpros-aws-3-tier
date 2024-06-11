

variable "name_prefix" {
  type        = string
  description = "The VPC name"

}

####################################
#  VPC
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

####################################
#  VPC Flow Log
####################################

variable "enable_flow_log" {
  description = "Flag to enable or disable flow log"
  type        = bool
  default     = false
}

variable "log_destination_arn" {
  description = "The arn for the log destination. e.g s3 bucket  arn"
  type        = string
}

variable "log_destination_type" {
  description = "Where to send the logs. Could be s3, kinesis-data-firehose, or cloud-watch-logs"
  type        = string
  default     = "s3"
}

variable "log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL."
  type        = string
  default     = "ALL"
}

#####################################
#  Subnets
#####################################

variable "enable_internet_gateway" {
  description = "Toggle creation of Internet Gateway"
  type        = bool
  default     = false
}


variable "subnets" {
  description = "A variable holding all subnets"
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)
    is_private              = optional(bool, true)
    enable_nat              = optional(bool, false)
    nat_public_subnet_key   = optional(string, null)
    shared_route_table_ref  = optional(string, null)
    routes = optional(list(object({
      # route_table_id              = string
      name                        = string
      destination_cidr_block      = optional(string, null)
      destination_ipv6_cidr_block = optional(string, null)
      destination_prefix_list_id  = optional(string, null)
      carrier_gateway_id          = optional(string, null)
      core_network_arn            = optional(string, null)
      egress_only_gateway_id      = optional(string, null)
      gateway_id                  = optional(string, null)
      nat_gateway_ref             = optional(string, null)
      local_gateway_id            = optional(string, null)
      network_interface_id        = optional(string, null)
      transit_gateway_id          = optional(string, null)
      vpc_endpoint_id             = optional(string, null)
      vpc_peering_connection_id   = optional(string, null)
    })), [])

  }))

  default = {
    "first" = {
      cidr_block        = "10.0.200.0/24"
      availability_zone = "us-east-1a"
      routes = [
        {
          name                   = "test_1"
          destination_cidr_block = "0.0.0.0/0"
          gateway_id             = "casamigos"

        }
        # {
        #   name                   = "test_2"
        #   destination_cidr_block = "0.0.0.0/0"
        #   core_network_arn       = "casamigos"

        # }
      ]
      map_public_ip_on_launch = true
      is_private              = false
    }

    "second" = {
      cidr_block              = "10.0.205.0/24"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = false
      is_private              = true
      enable_nat              = true
      nat_public_subnet_key   = "first"
      routes = [
        {
          name                   = "test_3"
          destination_cidr_block = "0.0.0.0/0"
          nat_gateway_ref        = "second" # Document
        }
      ]
    }

    "third_subnet" = {
      cidr_block              = "10.0.206.0/24"
      availability_zone       = "us-east-1a" # Should be in the same availability zone as the shared NAT
      map_public_ip_on_launch = false
      is_private              = true
      shared_route_table_ref  = "second"
    }
  }
}
