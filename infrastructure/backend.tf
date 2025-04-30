terraform {
  backend "s3" {
    bucket         = "cyb590-tfstate-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "cyb590-tfstate-locks"
  }
}
