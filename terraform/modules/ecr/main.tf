# terraform/modules/ecr/main.tf

resource "aws_ecr_repository" "lift_model" {
  name                 = "lift-model-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Allow Lambda service to pull images from this repository
resource "aws_ecr_repository_policy" "lambda_pull" {
  repository = aws_ecr_repository.lift_model.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaECRImagePull"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  })
}
