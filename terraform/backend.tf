# ==============================================================================
# TERRAFORM BACKEND CONFIGURATION
# ==============================================================================
# Stores Terraform state in S3 with DynamoDB locking for team collaboration
# and CI/CD pipelines.
#
# Prerequisites (created via AWS CLI):
# - S3 bucket: strapi-terraform-state-839547328448
# - DynamoDB table: strapi-terraform-locks
# ==============================================================================

terraform {
  backend "s3" {
    bucket         = "strapi-terraform-state-839547328448"
    key            = "strapi/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "strapi-terraform-locks"
  }
}
