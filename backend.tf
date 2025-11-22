# terraform {
#   backend "s3" {
#     bucket = "andrii-mashtaler-terraform-state-bucket-lesson-8-9"
#     key = "lesson-8-9/terraform.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt = true
#   }
# }