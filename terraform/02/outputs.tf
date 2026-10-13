output "selected_vpc_id" {
  value = data.aws_vpc.selected
}

output "ec2_sg_id" {
  value = aws_security_group.ec2-sg.id
}

output "ec2_role_name" {
  value = aws_iam_role.ec2-role.name
}
