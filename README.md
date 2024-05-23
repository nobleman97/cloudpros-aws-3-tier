# Perizer AWS VPC Module

This module helps to automate the creation of a VPC and its associated resources (e.g Subnets, route tables and gateways).


## Usage Notes:
When called, this module creates a **VPC**, a **public subnet** ( with an IGW and public route table ) and a **private subnet**. In the state, the private subnets are not really usable. To enable the private subnets, you need to set the variable `enable_private_subnets` = `true`. Setting this will provision a NAT gateway and private route table and route to allow the private subnets reach the internet.

To add or remove subnets, simply add or remove objects from the `public_subnets` or `private_subnets` variables. 



## Useful Links:
 - [aws_vpc | Resources | hashicorp/aws | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
 - [aws_subnet | Resources | hashicorp/aws | Terraform | Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)


### To-Do
Consider the possibility of adding Security Groups appropriately.
