# terraform/environments/dev/ecr.tf

resource "aws_ecr_repository" "lift_model" {
  name                 = "lift-model-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}
