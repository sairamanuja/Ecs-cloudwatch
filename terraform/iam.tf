# ==============================================================================
# IAM ROLES FOR ECS
# ==============================================================================

# ECS Task Execution Role
# This role is used by ECS to pull container images and write logs
resource "aws_iam_role" "ecs_execution" {
  name        = "${var.project_name}-execution-role"
  description = "ECS task execution role for ${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-execution-role"
    Service     = "ecs"
  }
}

# ECS Task Role
# This role is used by the application running in the container
resource "aws_iam_role" "ecs_task" {
  name        = "${var.project_name}-task-role"
  description = "ECS task role for ${var.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-task-role"
    Service     = "ecs"
  }
}

# ==============================================================================
# IAM POLICY ATTACHMENTS
# ==============================================================================

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
