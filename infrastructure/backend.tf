# backend.tf (optional if using remote state)
terraform {
  backend "s3" {
    bucket = "my-tf-state-bucket"
    key    = "terraform.tfstate"
    region = "us-west-1"
  }
}

