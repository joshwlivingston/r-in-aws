# modules/lambda/main.tf

# IAM Role
resource "aws_iam_role" "lambda" {
  name = "lift-model-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Permissions - cloudwatch logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions - read-only data access
## Define
resource "aws_iam_policy" "s3_read_access" {
  name        = "lift-model-s3-read-${var.environment}"
  description = "Allow Lambda to read data.csv"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Bucket-level actions
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.data_bucket.arn]
      },
      {
        # Object-level actions
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.data_bucket.arn}/*"]
      }
    ]
  })
}

## Attach
resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.s3_read_access.arn
}

# S3 Bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = "lift-model-data-${var.environment}"
}

# Upload the file to S3
resource "aws_s3_object" "model_data" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "data.csv"
  source = var.data_file_path

  # Tracks changes: if you edit the CSV locally, Terraform re-uploads it
  etag = filemd5(var.data_file_path)
}

# Lambda Function
resource "aws_lambda_function" "lift_model" {
  function_name = "calculate_lift_${var.environment}"
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"

  image_uri = "${var.ecr_repository_url}:${var.image_tag}"

  memory_size = var.memory_size
  timeout     = var.timeout

  environment {
    variables = {
      ENV            = var.environment
      S3_BUCKET_NAME = aws_s3_bucket.data_bucket.id
      S3_DATA_KEY    = aws_s3_object.model_data.key
    }
  }
}
