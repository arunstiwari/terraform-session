locals {
  name = "${var.project_name}-${terraform.workspace}-ecs"
}

resource "aws_ecr_repository" "this" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}



resource "aws_security_group" "vpc-link-sg" {
  name        = "${local.name}-vpc-link-sg"
  description = "Security group for VPC link"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "alb-sg" {
  name        = "${local.name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
}
resource "aws_security_group" "ecs-task-sg" {
  name        = "${local.name}-ecs-task-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "vpc_link_to_alb" {
  security_group_id            = aws_security_group.vpc-link-sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_vpc_link" {
  security_group_id            = aws_security_group.alb-sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.vpc-link-sg.id
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_task" {
  security_group_id            = aws_security_group.alb-sg.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs-task-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_task_from_alb" {
  security_group_id            = aws_security_group.ecs-task-sg.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_to_other" {
  security_group_id = aws_security_group.ecs-task-sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}
