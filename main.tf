provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "cyb590-diagnostic-bucket"
  tags = {
    Purpose = "Pipeline Diagnostic Test"
  }
}
