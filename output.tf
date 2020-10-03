output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private-2.id
}

output "public_instance_sg_id" {
  value = aws_security_group.allow_public_instance_tls.id
}

output "private_instance_sg_id" {
  value = aws_security_group.allow_private_instance_tls.id
}

