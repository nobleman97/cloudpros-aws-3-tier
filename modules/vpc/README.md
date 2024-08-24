# Unofficial AWS VPC Module

This module helps to automate the creation of a VPC and its associated resources (e.g Subnets, route tables and gateways).

<p text-align=center>
<img src=./arch.drawio.svg width=90% >
</p>

## Usage Notes:
When called, this module creates a **VPC**. You can choose to also create **public subnets** ( with an IGW and public route table), **private subnets** and NAT gateways. By default, when private subnets are created, they don't have NAT gateways. To add a NAT for a private subnet, set `enable_nat = true` in the *.tfvars file. Setting this will provision a _NAT gateway_, _private route table_ and _route_ for each private subnet where `enable_nat = true`, hence allowing the private subnets reach the internet.

> Important: In this scenario, ensure that the `nat_gateway_ref` matches the name of the subnet


```sh
...
    "second" = {        # This...
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
            nat_gateway_ref        = "second"     # ...Should match this
            }
        ]
    }
...
```

We could also decide to attach a new private subnet to an existing NAT gateway. In that case, we would have to associate the subnet with the route table which points to the existing NAT.

```sh
...
    "third_subnet" = {
        cidr_block              = "10.0.206.0/24"
        availability_zone       = "us-east-1a" # Should be in the same availability zone as the shared NAT
        map_public_ip_on_launch = false
        enable_nat              = false
        is_private              = true
        shared_route_table_ref  = "second" # This points to a route table that was created and associated with an existing NAT
    }
...
```


To add or remove subnets, simply add or remove objects from the `subnets` variables.



## Useful Links:
 - [aws_vpc | Resources | hashicorp/aws | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
 - [aws_subnet | Resources | hashicorp/aws | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)


### To-Do
Consider the possibility of adding Security Groups appropriately.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 5.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/eip) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/flow_log) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/nat_gateway) | resource |
| [aws_route.carrier_gateway_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.core_network_arn](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.egress_only_gateway_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.gateway_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.local_gateway_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.nat_gateway_ref](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.network_interface_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.transit_gateway_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.vpc_endpoint_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route.vpc_peering_connection_id](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_shared_nat](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/resources/vpc) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/5.5.0/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_log_bucket_name"></a> [log\_bucket\_name](#input\_log\_bucket\_name) | Name of Bucket where you want to send logs | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The VPC name | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames or not | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support or not | `bool` | `true` | no |
| <a name="input_enable_internet_gateway"></a> [enable\_internet\_gateway](#input\_enable\_internet\_gateway) | Toggle creation of Internet Gateway | `bool` | `false` | no |
| <a name="input_log_destination_type"></a> [log\_destination\_type](#input\_log\_destination\_type) | Where to send the logs. Could be s3, kinesis-data-firehose, or cloud-watch-logs | `string` | `"s3"` | no |
| <a name="input_log_traffic_type"></a> [log\_traffic\_type](#input\_log\_traffic\_type) | The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL. | `string` | `"ALL"` | no |
| <a name="input_region"></a> [region](#input\_region) | Default region to deploy resources to | `string` | `"us-east-1"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A variable holding all subnets | <pre>map(object({<br>    cidr_block              = string<br>    availability_zone       = string<br>    map_public_ip_on_launch = optional(bool, false)<br>    is_private              = optional(bool, true)<br>    enable_nat              = optional(bool, false)<br>    nat_public_subnet_key   = optional(string, null)<br>    shared_route_table_ref  = optional(string, null)<br>    routes = optional(list(object({<br>      # route_table_id              = string<br>      name                        = string<br>      destination_cidr_block      = optional(string, null)<br>      destination_ipv6_cidr_block = optional(string, null)<br>      destination_prefix_list_id  = optional(string, null)<br>      carrier_gateway_id          = optional(string, null)<br>      core_network_arn            = optional(string, null)<br>      egress_only_gateway_id      = optional(string, null)<br>      gateway_id                  = optional(string, null)<br>      nat_gateway_ref             = optional(string, null)<br>      local_gateway_id            = optional(string, null)<br>      network_interface_id        = optional(string, null)<br>      transit_gateway_id          = optional(string, null)<br>      vpc_endpoint_id             = optional(string, null)<br>      vpc_peering_connection_id   = optional(string, null)<br>    })), [])<br><br>  }))</pre> | <pre>{<br>  "first": {<br>    "availability_zone": "us-east-1a",<br>    "cidr_block": "10.0.200.0/24",<br>    "is_private": false,<br>    "map_public_ip_on_launch": true,<br>    "routes": [<br>      {<br>        "destination_cidr_block": "0.0.0.0/0",<br>        "gateway_id": "casamigos",<br>        "name": "test_1"<br>      }<br>    ]<br>  },<br>  "second": {<br>    "availability_zone": "us-east-1a",<br>    "cidr_block": "10.0.205.0/24",<br>    "enable_nat": true,<br>    "is_private": true,<br>    "map_public_ip_on_launch": false,<br>    "nat_public_subnet_key": "first",<br>    "routes": [<br>      {<br>        "destination_cidr_block": "0.0.0.0/0",<br>        "name": "test_3",<br>        "nat_gateway_ref": "second"<br>      }<br>    ]<br>  },<br>  "third_subnet": {<br>    "availability_zone": "us-east-1a",<br>    "cidr_block": "10.0.206.0/24",<br>    "is_private": true,<br>    "map_public_ip_on_launch": false,<br>    "shared_route_table_ref": "second"<br>  }<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The VPC cidr | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->