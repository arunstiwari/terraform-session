
/*
0.2 Create a Security Group (Ingress Rule and Egress Rule)
0.3 Create an IAM Role for the EC2 instance
0.4 Create an IAM Policy for the EC2 instance
0.5 Create an IAM Instance Profile for the EC2 instance
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



resource "aws_iam_role" "ec2-role" {
  name               = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role-policy.json

  tags = {
    Name = "${local.name}-role"
  }
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


# Create an EC2 instance 
//ami-0f7a6ae0b7f75d496
resource "aws_instance" "ssm_instance" {
  #   ami                    = "ami-0f7a6ae0b7f75d496"
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-instance-profile.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "${local.name}-ec2"
  }

  #   depends_on = [aws_iam_instance_profile.ec2-instance-profile]
}
/**
5. Specify the  volume and Storage
6. Enable the DNS hostname 
7. We will configure the EC2 so that it remains private 
8. Configure the metadata version for enhanced security
9. Configure the User Data for the EC2 instance
10. Associate the IAM Role and Policy with the EC2 instance
*/

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "${local.name}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_ingress" {
  security_group_id            = aws_security_group.vpc_endpoints.id
  description                  = "Allow inbound HTTPS traffic from VPC endpoints"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2-sg.id
}


resource "aws_vpc_endpoint" "ssm_endpoint" {
  for_each          = toset(["ssm", "ssmmessages", "ec2messages"])
  vpc_id            = data.aws_vpc.selected.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ec2-sg.id]

  subnet_ids = [var.subnet_id]

  private_dns_enabled = true

  tags = {
    Name = "${local.name}-${each.key}-endpoint"
  }
}


resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = data.aws_vpc.selected.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.instance_subnet.id]

  tags = {
    Name = "${local.name}-s3-vpce"
  }
}


data "aws_region" "current" {}
