# terraform {
#   backend "s3" {
#     bucket         = "andrii-mashtaler-terraform-state-lesson-7"
#     key            = "lesson-7/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }