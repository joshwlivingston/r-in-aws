# environments/dev/terraform.tfvars
region         = "us-east-1"
environment    = "dev"
image_tag      = "latest"
memory_size    = 512
timeout        = 60
data_file_path = "../../../data/dev/data.csv"
github_repo      = "joshwlivingston/r-in-aws"
data_bucket_name = "cmpex-data-dev"
