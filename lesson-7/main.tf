terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

# Connect S3 and DynamoDB module
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "andrii-mashtaler-terraform-state-lesson-7"
  table_name  = "terraform-locks"
}

# Connect VPC module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-7-vpc"
}

# Connect ECR module
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-7-django-app"
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "eks-cluster-lesson-7"
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t2.micro"
  desired_size    = 1
  max_size        = 2
  min_size        = 1
}
