output "ecr_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.ecr_url
}

output "ecr_name" {
  description = "The name of the ECR repository"
  value       = module.ecr.ecr_name
}

output "image_tag" {
  description = "The image tag defined in the lambda module"
  value       = module.lambda_function.image_tag
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda_function.function_name
}

output "github_deploy_role_arn" {
  description = "ARN of the IAM role for GitHub Actions OIDC deployment"
  value       = module.github_oidc.role_arn
}
