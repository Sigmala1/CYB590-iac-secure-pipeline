#!/bin/bash
set -e

echo "Validating project infrastructure code..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed. Please install it first."
    exit 1
fi

# Check if tfsec is installed
if ! command -v tfsec &> /dev/null; then
    echo "Warning: tfsec is not installed. Security scanning will be skipped."
    echo "Install with: brew install tfsec or go install github.com/aquasecurity/tfsec/cmd/tfsec@latest"
fi

# Validate Terraform files
echo "Running terraform fmt check..."
terraform fmt -check -recursive || {
    echo "Error: Terraform files are not properly formatted."
    echo "Run 'terraform fmt -recursive' to fix formatting issues."
    exit 1
}

echo "Running terraform init..."
terraform init -backend=false

echo "Running terraform validate..."
terraform validate || {
    echo "Error: Terraform validation failed."
    exit 1
}

# Run tfsec if installed
if command -v tfsec &> /dev/null; then
    echo "Running tfsec security scan..."
    tfsec . --soft-fail || {
        echo "Warning: Security issues detected by tfsec. Review the output above."
    }
fi

# Validate Docker build if Dockerfile exists
if [ -f "Dockerfile" ]; then
    echo "Validating Dockerfile..."
    docker build -t validation-test . || {
        echo "Error: Docker build failed."
        exit 1
    }
    docker rmi validation-test
fi

# Validate PHP files if they exist
if [ -f "index.php" ]; then
    echo "Validating PHP syntax..."
    php -l index.php || {
        echo "Error: PHP syntax validation failed."
        exit 1
    }
fi

echo "All validation checks passed successfully!"
