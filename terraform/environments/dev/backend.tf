# environments/dev/backend.tf

terraform {
  backend "s3" {
    bucket       = "cmpex-tfstate"
    key          = "dev/terraform.tfstate" # Unique path inside bucket
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
