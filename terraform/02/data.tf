data "aws_vpc" "selected" {
  id = "vpc-0af5e82c5fef4566e"
}

data "aws_iam_policy_document" "ec2-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy" "ec2-policy" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_route_table" "instance_subnet" {
  subnet_id = data.aws_subnet.default.id
}

data "aws_subnet" "default" {
  id = var.subnet_id
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

