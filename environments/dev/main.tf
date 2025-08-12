terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  
  backend "s3" {
    bucket         = "joshua-terraform-state-zc3nwpgp"
    key            = "environments/dev/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "joshua-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Ubuntu 24.04 LTS AMI (eu-north-1)
locals {
  ubuntu_ami_id = "ami-042b4708b1d05f512"
}

# VPC Module from GitHub
module "vpc" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/vpc?ref=v1.0.3"
  
  vpc_cidr               = var.vpc_cidr
  availability_zones     = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  
  tags = var.common_tags
}

# Web Server Security Group
module "web_sg" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/security-group?ref=v1.0.3"
  
  name        = "${var.environment}-web-server-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id
  
  ingress_rules = var.web_ingress_rules
  
  tags = merge(var.common_tags, {
    Name = "${var.environment}-web-server-sg"
  })
}

# Database Security Group
module "db_sg" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/security-group?ref=v1.0.3"
  
  name        = "${var.environment}-database-sg"
  description = "Security group for database servers"
  vpc_id      = module.vpc.vpc_id
  
  ingress_rules = var.db_ingress_rules
  
  tags = merge(var.common_tags, {
    Name = "${var.environment}-database-sg"
  })
}

# Web Server EC2 Instance
module "web_server" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/ec2?ref=v1.0.3"
  
  instance_count              = var.web_instance_count
  instance_type              = var.web_instance_type
  ami_id                     = local.ubuntu_ami_id
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.web_sg.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile       = "ec2-game-access-profile"
  
  user_data = var.web_user_data
  
  tags = merge(var.common_tags, {
    Role = "web-server"
    Name = "${var.environment}-web-server"
  })
}

# Database Server EC2 Instance
module "db_server" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/ec2?ref=v1.0.3"
  
  instance_count              = var.db_instance_count
  instance_type              = var.db_instance_type
  ami_id                     = local.ubuntu_ami_id
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.db_sg.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile       = "ec2-game-access-profile"
  
  user_data = var.db_user_data
  
  tags = merge(var.common_tags, {
    Role = "database-server"
    Name = "${var.environment}-db-server"
  })
}

# Application Load Balancer
module "alb" {
  source = "git::https://github.com/Kofijoo/terraform-aws-modules.git//modules/alb?ref=v1.0.3"
  
  name                  = "${var.environment}-alb"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.public_subnet_ids
  security_group_ids   = [module.web_sg.security_group_id]
  target_instance_ids  = module.web_server.instance_ids
  health_check_path    = "/"
  
  tags = merge(var.common_tags, {
    Name = "${var.environment}-alb"
    Role = "load-balancer"
  })
}