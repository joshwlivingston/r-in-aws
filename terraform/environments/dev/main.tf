# environments/dev/main.tf
#
# Use aws provider and set dev environment variables

provider "aws" {
  region = var.region
}

module "lambda_function" {
  source             = "../../modules/lambda"
  environment        = var.environment
  image_tag          = var.image_tag
  memory_size        = var.memory_size
  timeout            = var.timeout
  data_file_path     = var.data_file_path
  ecr_repository_url = var.ecr_repository_url
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
}

module "github_oidc" {
  source               = "../../modules/github-oidc"
  github_repo          = var.github_repo
  environment          = var.environment
  region               = var.region
  create_oidc_provider = false # Provider already exists in this AWS account
  data_bucket_name     = var.data_bucket_name
}
