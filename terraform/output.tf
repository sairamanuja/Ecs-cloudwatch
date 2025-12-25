# ==============================================================================
# ECS OUTPUTS
# ==============================================================================
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

# ==============================================================================
# DATABASE OUTPUTS
# ==============================================================================
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.strapi.endpoint
  sensitive   = false
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.strapi.db_name
}

# ==============================================================================
# NETWORK OUTPUTS
# ==============================================================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = [aws_subnet.a.id, aws_subnet.b.id]
}

output "security_group_ecs_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}

# ==============================================================================
# LOAD BALANCER OUTPUTS
# ==============================================================================
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.strapi.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.strapi.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.strapi.zone_id
}

output "target_group_blue_arn" {
  description = "ARN of the Blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "target_group_green_arn" {
  description = "ARN of the Green target group"
  value       = aws_lb_target_group.green.arn
}

# ==============================================================================
# CODEDEPLOY OUTPUTS
# ==============================================================================
output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.strapi.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.strapi.deployment_group_name
}

# ==============================================================================
# CLOUDWATCH LOG GROUP
# ==============================================================================
output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.strapi.name
}

# ==============================================================================
# APPLICATION URL
# ==============================================================================
output "application_url" {
  description = "URL to access the Strapi application"
  value       = "http://${aws_lb.strapi.dns_name}"
}

output "security_group_rds_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# ==============================================================================
# ECR OUTPUTS
# ==============================================================================
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.strapi.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.strapi.name
}
