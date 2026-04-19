# environments/prod/backend.tf

terraform {
  backend "s3" {
    bucket       = "cmpex-tfstate"
    key          = "prod/terraform.tfstate" # Unique path inside bucket
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
