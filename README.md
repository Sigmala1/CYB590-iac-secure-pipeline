## Repository Configuration

### GitHub Secrets

This project uses the following GitHub repository secrets for secure authentication:

- `AWS_OIDC_ROLE`: IAM role ARN for OpenID Connect authentication with AWS
- `TF_API_TOKEN`: HashiCorp Cloud Platform API token for Terraform Cloud integration

These secrets enable secure, key-less authentication between GitHub Actions and the cloud services:

1. **AWS OIDC Integration**: Uses OpenID Connect to authenticate GitHub Actions workflows with AWS without storing long-lived credentials.

2. **Terraform Cloud Authentication**: Securely connects to HCP Terraform workspaces using API token authentication.

### Environment Setup

To set up these secrets in your forked repository:

1. Generate an AWS IAM role with appropriate permissions that trusts the GitHub OIDC provider
2. Create a Terraform Cloud API token for your workspace
3. Add these as repository secrets in your GitHub repository settings# PHP Infrastructure as Code on AWS ECS

A PHP application that demonstrates Infrastructure as Code principles for deployment to AWS ECS using Terraform and GitHub Actions.

## Overview

This project provides a complete CI/CD pipeline for deploying a PHP web application to Amazon Elastic Container Service (ECS). It demonstrates Infrastructure as Code (IaC) principles with Terraform to provision and manage AWS resources in a secure, repeatable manner. The project utilizes HashiCorp Cloud Platform (HCP) Terraform workspaces for enhanced collaboration and state management.

## Technology Stack

- **PHP 8.4**: Application runtime (recently upgraded from 8.2)
- **Docker**: Containerization
- **AWS ECS**: Container orchestration
- **Terraform**: Infrastructure as code
- **GitHub Actions**: CI/CD pipeline

## Repository Structure

- `Dockerfile`: Defines the PHP application container
- `.github/`: Contains GitHub Actions workflow configurations
  - `workflows/`: CI/CD pipeline definitions
  - `dependabot.yml`: Automated dependency updates configuration
- `deployment/`: Terraform configurations for AWS infrastructure
  - `modules/vpc/`: VPC module for network infrastructure
    - `main.tf`: Main VPC configuration
    - `variables.tf`: VPC module variables
  - `main.tf`: Main Terraform configuration
  - `variables.tf`: Terraform variables
  - `terraform.tfvars`: Terraform variable values
- `index.php`: Simple PHP application code

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Terraform v1.0+ installed locally
- Docker installed locally
- GitHub account

### Local Development

1. Clone the repository:
   ```
   git clone https://github.com/Sigmala1/CYB590-iac-secure-pipeline.git
   cd CYB590-iac-secure-pipeline
   ```

2. Build and run the Docker container locally:
   ```
   docker build -t php-iac-demo .
   docker run -p 8080:80 php-iac-demo
   ```

3. Access the application at http://localhost:8080

### Infrastructure Deployment

1. Navigate to the deployment directory:
   ```
   cd deployment
   ```

2. Initialize Terraform with the HCP workspace:
   ```
   terraform init
   terraform workspace select <workspace-name>
   ```

3. Plan the infrastructure changes:
   ```
   terraform plan
   ```

4. Apply the infrastructure:
   ```
   terraform apply
   ```

Environment-specific configurations are managed through HCP Terraform workspaces, allowing for consistent deployment across development, staging, and production environments.

### CI/CD Pipeline

This project uses GitHub Actions for CI/CD. The pipeline will:

1. Build the Docker image
2. Run security scans
3. Push the image to ECR
4. Apply Terraform configurations
5. Deploy to ECS

Dependabot is configured to automatically create pull requests for dependency updates, including Docker image updates.

The CI/CD pipeline authenticates to AWS and Terraform Cloud using the configured repository secrets (AWS_OIDC_ROLE and TF_API_TOKEN). This approach eliminates the need for storing long-lived credentials and follows security best practices for CI/CD authentication.

## Security Features

- Container security scanning in the CI/CD pipeline
- Infrastructure as code security checks with Terraform
- Secure AWS configurations following best practices
- Automated dependency updates via Dependabot
- VPC configuration with proper network isolation
- OpenID Connect (OIDC) authentication for AWS access
- Secure management of secrets in GitHub Actions

## Terraform State Management

The project uses remote state management with HashiCorp Cloud Platform (HCP) Terraform. State files are stored securely in workspaces with proper access controls, versioning, and encryption enabled. This approach provides:

- Centralized state management
- Team collaboration features
- Secure state locking
- Full state history and audit trail
- Integration with the CI/CD pipeline

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

Pull requests will be automatically scanned for security issues and code quality.

## License

MIT License

Copyright (c) 2025 Sigmala1

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files.
