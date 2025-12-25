# ==============================================================================
# GENERAL CONFIGURATION
# ==============================================================================
variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "strapi-ramanuja"
}

# ==============================================================================
# ECS CONFIGURATION
# ==============================================================================
variable "cpu" {
  description = "CPU units for ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory in MiB for ECS task"
  type        = number
  default     = 1024
}

# ==============================================================================
# DATABASE CONFIGURATION
# ==============================================================================
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "strapidb"
}

variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  default     = "strapi"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

# ==============================================================================
# STRAPI CONFIGURATION
# ==============================================================================
variable "app_keys" {
  description = "Strapi application keys for session encryption"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for user authentication"
  type        = string
  sensitive   = true
}

variable "admin_jwt_secret" {
  description = "Admin JWT secret for admin authentication"
  type        = string
  sensitive   = true
}

variable "api_token_salt" {
  description = "Salt for API token generation"
  type        = string
  sensitive   = true
}

variable "transfer_token_salt" {
  description = "Salt for transfer token generation"
  type        = string
  sensitive   = true
}