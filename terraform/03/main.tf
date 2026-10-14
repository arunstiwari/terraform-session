locals {
  name      = "${var.project_name}-${terraform.workspace}-ecs"
  image_uri = "714284856105.dkr.ecr.eu-west-1.amazonaws.com/fil-session-default-ecs:v2"
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

resource "aws_lb" "alb" {
  name               = "${local.name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = var.subnet_ids

  #   drop_invalid_header_fields = true 
}

resource "aws_lb_target_group" "fastapi-app" {
  name                 = "${local.name}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi-app.arn
  }
}


# Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}


# Creating ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.name}-ecs-cluster"
}

# Create Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${local.name}"
  retention_in_days = 7
}

# Creating ECS Task Definition  
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${local.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = var.cpu_architecture
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "${local.name}-container"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "fastapi"
        }
      }
    }
  ])
}

# Creating ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${local.name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs-task-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi-app.arn
    container_name   = "${local.name}-container"
    container_port   = var.container_port
  }

  # Circuit breaker configuration

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  wait_for_steady_state = true

}

// Commenting out VPC endpoint and related security group resources for Fidelity environment

# resource "aws_security_group" "vpce-sg" {
#   name        = "${local.name}-vpce-sg"
#   description = "Security group for VPC endpoint"
#   vpc_id      = var.vpc_id
# }

# resource "aws_vpc_security_group_ingress_rule" "vpce_ingress" {
#   from_port                    = 443
#   to_port                      = 443
#   ip_protocol                  = "tcp"
#   security_group_id            = aws_security_group.vpce-sg.id
#   referenced_security_group_id = aws_security_group.ecs-task-sg.id
# }

# resource "aws_vpc_endpoint" "vpce" {
#   for_each            = toset(["ecr.dkr", "ecr.api", "logs"])
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
#   vpc_endpoint_type   = "Interface"
#   security_group_ids  = [aws_security_group.vpce-sg.id]
#   subnet_ids          = var.subnet_ids
#   private_dns_enabled = true
# }

# data "aws_route_table" "main" {
#   for_each  = toset(var.subnet_ids)
#   subnet_id = each.value
# }

# resource "aws_vpc_endpoint" "s3_gateway" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = distinct([for rt in data.aws_route_table.main : rt.id])
# }



# API Gateway VPC Link (To be commented For Fidelity)
resource "aws_apigatewayv2_vpc_link" "api_gw_vpc_link" {
  name               = "${local.name}-api-gw-vpc-link"
  security_group_ids = [aws_security_group.vpce-sg.id]
  subnet_ids         = var.subnet_ids
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${local.name}-api"
  description = "API Gateway for ${local.name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#  proxy -> http://alb:port

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_alb" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_apigatewayv2_vpc_link.api_gw_vpc_link.id

  integration_target = aws_lb.alb.arn
  uri                = "http://${aws_lb.alb.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_alb" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.root_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_apigatewayv2_vpc_link.api_gw_vpc_link.id

  integration_target = aws_lb.alb.arn
  uri                = "http://${aws_lb.alb.dns_name}/"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_resource.proxy,
      aws_api_gateway_method.proxy_any,
      aws_api_gateway_method.root_any,
      aws_api_gateway_integration.proxy_alb,
      aws_api_gateway_integration.root_alb
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name

  method_path = "*/*"

  settings {
    metrics_enabled        = true
    throttling_rate_limit  = 50
    throttling_burst_limit = 100
  }
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}
