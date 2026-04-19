# modules/lambda/outputs.tf
#
# Defines variables that can be accessed externally (e.g., for `docker push`)

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lift_model.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda"
  value       = aws_iam_role.lambda.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lift_model.function_name
}

output "image_tag" {
  description = "The Docker image tag used for this deployment"
  value       = var.image_tag
}
