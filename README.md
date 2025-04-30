# PHP Hello World on AWS ECS

This is a simple PHP "Hello World" application that demonstrates deployment to AWS ECS using Terraform and GitHub Actions.

## Project Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions workflow file
├── modules/
│   └── vpc/                 # Terraform VPC module
│       ├── main.tf
│       └── variables.tf
├── index.php                # PHP Hello World application
├── Dockerfile               # Docker configuration
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Terraform variables
└── terraform.tfvars         # Terraform variable values
```

## Application

A simple PHP application that displays "Hello World" along with the current server time.

## Infrastructure

This project uses Terraform to provision the following AWS resources:

- VPC with public and private subnets
- NAT Gateway and Internet Gateway
- ECR Repository for storing Docker images
- ECS Cluster, Task Definition, and Service
- Application Load Balancer
- Security Groups
- IAM Roles
- CloudWatch Log Group

## Deployment Pipeline

GitHub Actions is used to create a CI/CD pipeline that:

1. Runs tfsec to scan Terraform code for security issues
2. Deploys the infrastructure using Terraform
3. Builds and pushes the Docker image to ECR
4. Updates the ECS service to use the new image

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository
- AWS credentials configured as GitHub secrets

## GitHub Secrets Required

- `AWS_ROLE_TO_ASSUME`: ARN of the IAM role with necessary permissions

## Setup Instructions

1. Push this code to your GitHub repository
2. Configure GitHub Secrets with your AWS credentials
3. Push to the main branch to trigger the deployment

## Environment

This project is configured for the "development" environment. Additional environments can be added by creating new Terraform variable files and updating the GitHub workflow.

## Security

The infrastructure includes:
- HTTPS load balancer
- Private subnets for container hosting
- Security groups with minimal access
- tfsec scanning in the CI/CD pipeline
