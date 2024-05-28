locals {
  public_subnets = {
    for key, subnet in aws_subnet.this :
    key => subnet.id if subnet.map_public_ip_on_launch == true
  }

  private_subnets = {
    for key, subnet in aws_subnet.this :
    key => subnet.id if subnet.map_public_ip_on_launch == false
  }

}