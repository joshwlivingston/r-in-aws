# modules/ecr/outputs.tf

output "ecr_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.lift_model.repository_url
}

output "ecr_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.lift_model.name
}
