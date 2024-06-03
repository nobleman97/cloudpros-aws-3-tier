locals {

  routes = flatten(
    [
      for key, subnet in var.subnets : [
        for route in subnet.routes : {
          subnet                      = key
          name                        = route.name
          destination_cidr_block      = route.destination_cidr_block
          destination_ipv6_cidr_block = route.destination_ipv6_cidr_block
          destination_prefix_list_id  = route.destination_prefix_list_id
          carrier_gateway_id          = route.carrier_gateway_id
          core_network_arn            = route.core_network_arn
          egress_only_gateway_id      = route.egress_only_gateway_id
          gateway_id                  = route.gateway_id
          nat_gateway_ref             = route.nat_gateway_ref
          local_gateway_id            = route.local_gateway_id
          network_interface_id        = route.network_interface_id
          transit_gateway_id          = route.transit_gateway_id
          vpc_endpoint_id             = route.vpc_endpoint_id
          vpc_peering_connection_id   = route.vpc_peering_connection_id
        }
      ]

    ]
  )
}