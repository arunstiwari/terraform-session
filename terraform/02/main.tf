
/*
0.2 Create a Security Group (Ingress Rule and Egress Rule)
0.3 Create an IAM Role for the EC2 instance
0.4 Create an IAM Policy for the EC2 instance
1. Choose the AMI
2. Specify the instance type
3. Specify the VPC Id
4. Specify the subnet id
4.5 Attach the security group to EC2 instance
5. Specify the  volume and Storage
6. Enable the DNS hostname 
7. We will configure the EC2 so that it remains private 
8. Configure the metadata version for enhanced security
9. Configure the User Data for the EC2 instance
10. Associate the IAM Role and Policy with the EC2 instance
11. Launch the EC2 instance
*/
locals {
  name = "${var.name}-ssm-instance"
}

resource "aws_security_group" "ec2-sg" {
  name        = "${local.name}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "${local.name}-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2-sg-egress" {
  security_group_id = aws_security_group.ec2-sg.id
  description       = "Allow outbound HTTPS traffic to all destinations"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Creating an IAM Instance Role 

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

resource "aws_iam_role" "ec2-role" {
  name               = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role-policy.json

  tags = {
    Name = "${local.name}-role"
  }
}

data "aws_iam_policy" "ec2-policy" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2-role-attachment" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.ec2-policy.arn
}

# Create an instance Profile
resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.ec2-role.name
}

