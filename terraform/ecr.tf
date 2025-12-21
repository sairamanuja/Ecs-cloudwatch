# ==============================================================================
# ECR REPOSITORY
# ==============================================================================
resource "aws_ecr_repository" "strapi" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

# ==============================================================================
# ECR LIFECYCLE POLICY
# ==============================================================================
# Keeps only the last 10 images to save storage costs
resource "aws_ecr_lifecycle_policy" "strapi" {
  repository = aws_ecr_repository.strapi.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
