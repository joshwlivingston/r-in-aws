# modules/github-oidc/variables.tf

variable "github_repo" {
  type        = string
  description = "GitHub repository in 'owner/repo' format (e.g., 'joshwlivingston/r-in-aws')"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider. Set to false if it already exists in this account (only one allowed per account)."
  default     = true
}

variable "data_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for Lambda model data"
}
