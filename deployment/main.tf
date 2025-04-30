terraform { 
  cloud { 
    
    organization = "AaronSiegman" 

    workspaces { 
      name = "PHP_IaC" 
    } 
  } 
  required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
      }
  }
}
provider "aws" {
  region = var.aws_region
  

}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}

# Set up the networking resources
module "vpc" {
  source = "./modules/vpc"
  
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# Set up ECR repository
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Set up ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  }
}

# Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-task-execution-role"
    Environment = var.environment
  }
}

# Attach policies to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 30
  
  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Security Group for ECS Service
resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-${var.environment}-ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-service-sg"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_service.id]
  subnets            = module.vpc.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
  }
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-listener"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  
  network_configuration {
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = module.vpc.private_subnet_ids
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.project_name}-${var.environment}"
    container_port   = 80
  }
  
  depends_on = [
    aws_lb_listener.app
  ]
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
  }
}

# Output the ALB DNS name
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}
