#!/bin/bash
set -e

# Default values
ENVIRONMENT="development"
AWS_REGION="us-east-1"
PROJECT_NAME="php-hello-world"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --environment=*)
      ENVIRONMENT="${1#*=}"
      shift
      ;;
    --region=*)
      AWS_REGION="${1#*=}"
      shift
      ;;
    --project=*)
      PROJECT_NAME="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Calculate bucket and table names
BUCKET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-terraform-state"
TABLE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-terraform-locks"

echo "Initializing Terraform remote state with:"
echo " - Environment: $ENVIRONMENT"
echo " - Region: $AWS_REGION"
echo " - Project: $PROJECT_NAME"
echo " - S3 Bucket: $BUCKET_NAME"
echo " - DynamoDB Table: $TABLE_NAME"
echo ""

# First apply to create the S3 bucket and DynamoDB table
echo "Creating S3 bucket and DynamoDB table with local state..."
terraform init
terraform apply -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks -var="environment=${ENVIRONMENT}" -var="aws_region=${AWS_REGION}" -var="project_name=${PROJECT_NAME}" -auto-approve

# Update backend configuration
echo ""
echo "Remote storage resources created. Updating config.tf..."

# Create the backend configuration
sed -i '' 's|^/\*|\# Previous local state config|g' config.tf
sed -i '' 's|\*/|# End of previous config|g' config.tf

# Generate updated backend config
cat > config.tf.new << EOF
# Backend configuration
terraform {
  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${TABLE_NAME}"
    encrypt        = true
  }
}

# Provider version constraints
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.4.0"
}
EOF

mv config.tf.new config.tf

# Reinitialize with remote state
echo ""
echo "Migrating state to remote storage..."
terraform init -force-copy

echo ""
echo "Remote state initialization complete! Your Terraform state is now stored in:"
echo "S3 Bucket: ${BUCKET_NAME}"
echo "DynamoDB Table: ${TABLE_NAME}"
