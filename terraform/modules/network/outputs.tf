output "security_group_id" {
  value = aws_security_group.private_subnet_sg.id
}

output "private_subnet" {
  value = aws_subnet.private_subnet.id
}

