# ==============================================================================
# TERRAFORM BACKEND CONFIGURATION
# ==============================================================================
# Stores Terraform state in S3 for team collaboration and CI/CD pipelines.
#
# Prerequisites (created via AWS CLI):
# - S3 bucket: strapi-terraform-state-ramanuja
# ==============================================================================

terraform {
  backend "s3" {
    bucket  = "strapi-terraform-state-ramanuja"
    key     = "strapi/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
