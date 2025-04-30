variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "cyb590-pipeline-test-bucket"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}
