# terraform {
#   backend "s3" {
#     bucket = "terraform-state-bucket-andrii-mashtaler"
#     key = "terraform.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "use_lockfile"
#     encrypt = true
#   }
# }