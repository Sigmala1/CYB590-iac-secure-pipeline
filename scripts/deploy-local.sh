#!/bin/bash
set -e

# Default variables
ENVIRONMENT="development"
AWS_REGION="us-east-1"
ACTION="plan" # Default action is to plan only

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --environment=*)
      ENVIRONMENT="${key#*=}"
      shift
      ;;
    --region=*)
      AWS_REGION="${key#*=}"
      shift
      ;;
    --apply)
      ACTION="apply"
      shift
      ;;
    --destroy)
      ACTION="destroy"
      shift
      ;;
    *)
      echo "Unknown option: $key"
      echo "Usage: $0 [--environment=development|staging|production] [--region=us-east-1] [--apply] [--destroy]"
      exit 1
      ;;
  esac
done

echo "🚀 Starting local deployment process for $ENVIRONMENT environment in $AWS_REGION"

# Run validation script first
echo "Running validation checks..."
./scripts/validate.sh || {
  echo "❌ Validation failed. Please fix the issues and try again."
  exit 1
}

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Export environment variables for Terraform
export TF_VAR_environment="$ENVIRONMENT"
export TF_VAR_aws_region="$AWS_REGION"

# Run the appropriate Terraform command based on the action
case $ACTION in
  plan)
    echo "📝 Planning infrastructure changes..."
    terraform plan -var-file=terraform.tfvars
    ;;
  apply)
    echo "🏗️ Applying infrastructure changes..."
    terraform plan -var-file=terraform.tfvars -out=tfplan
    terraform apply tfplan
    
    # Build and push Docker image if infrastructure was deployed successfully
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_REPOSITORY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/php-hello-world-${ENVIRONMENT}"
    
    echo "🐳 Building and pushing Docker image to ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
    docker build -t $ECR_REPOSITORY:latest .
    docker push $ECR_REPOSITORY:latest
    
    # Update ECS service
    echo "🔄 Updating ECS service..."
    CLUSTER_NAME="php-hello-world-${ENVIRONMENT}-cluster"
    SERVICE_NAME="php-hello-world-${ENVIRONMENT}-service"
    aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment --region $AWS_REGION
    
    # Wait for service to stabilize
    echo "⏳ Waiting for ECS service to stabilize..."
    aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION
    
    # Output the ALB DNS
    ALB_DNS=$(terraform output -raw alb_dns_name)
    echo "✅ Deployment completed successfully!"
    echo "🌐 Your application is accessible at: http://${ALB_DNS}"
    ;;
  destroy)
    echo "💥 Destroying infrastructure..."
    terraform destroy -var-file=terraform.tfvars -auto-approve
    echo "✅ Infrastructure destroyed successfully."
    ;;
esac
