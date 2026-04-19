# modules/lambda/variables.tf

variable "environment" {
  type        = string
  description = "The name of the environment (e.g., dev, prod)"
}

variable "image_tag" {
  type        = string
  description = "The Docker image tag to deploy"
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB for the Lambda function"
}

variable "timeout" {
  type        = number
  description = "The maximum time the Lambda can run in seconds"
}

variable "data_file_path" {
  description = "The local path to the data.csv file"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
  default     = ""
}
