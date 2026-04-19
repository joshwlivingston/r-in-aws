# environments/prod/main.tf
#
# Use aws provider and set prod environment variables

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
