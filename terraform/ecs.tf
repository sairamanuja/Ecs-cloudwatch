# ==============================================================================
# ECS CLUSTER
# ==============================================================================
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# ==============================================================================
# ECS TASK DEFINITION
# ==============================================================================
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${aws_ecr_repository.strapi.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = aws_db_instance.strapi.db_name },
        { name = "DATABASE_USERNAME", value = aws_db_instance.strapi.username },
        { name = "DATABASE_PASSWORD", value = aws_db_instance.strapi.password },
        { name = "DATABASE_SSL", value = "true" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" },
        { name = "APP_KEYS", value = var.app_keys },
        { name = "JWT_SECRET", value = var.jwt_secret },
        { name = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
        { name = "API_TOKEN_SALT", value = var.api_token_salt },
        { name = "TRANSFER_TOKEN_SALT", value = var.transfer_token_salt }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "strapi"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task"
  }
}

# ==============================================================================
# ECS SERVICE
# ==============================================================================
resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight           = 10
    base            = 0
  }
  depends_on = [aws_db_instance.strapi, aws_lb_listener.http]

  network_configuration {
    subnets = [
      aws_subnet.a.id,
      aws_subnet.b.id
    ]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  health_check_grace_period_seconds = 300

  tags = {
    Name = "${var.project_name}-service"
  }
}

# ==============================================================================
# CLOUDWATCH LOGS
# ==============================================================================
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name    = "${var.project_name}-logs"
    Service = "ecs"
  }
}
