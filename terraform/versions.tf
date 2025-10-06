terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "<S3_BACKEND_BUCKET>"
    key    = "capstone/terraform.tfstate"
    region = "<REGION>"
  }
}

