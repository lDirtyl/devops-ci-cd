terraform {
  backend "s3" {
    bucket         = "andrii-mashtaler-terraform-state-001001"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

