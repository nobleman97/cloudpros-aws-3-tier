output "security_groups" {
  value = { for sg in keys(aws_security_group.main) :
    sg => aws_security_group.main.id
  }
}
