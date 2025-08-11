# Terraform AWS Deployment

**Author**: Joshua Agyekum  
**Project**: Terraform Multi-Repository Assignment

Infrastructure deployment using reusable Terraform modules from the `terraform-aws-modules` repository.

## Architecture

- **VPC**: Virtual Private Cloud with public/private subnets
- **Web Servers**: Apache servers in public subnets
- **Database Servers**: MariaDB servers in private subnets
- **NAT Gateway**: Internet access for private subnets
- **Security Groups**: Least privilege access control

## Environments

### Dev Environment
- **Path**: `environments/dev/`
- **Instance Types**: t3.micro (cost-optimized)
- **Instance Count**: 1 web server, 1 database server
- **NAT Gateway**: Single NAT Gateway
- **Network**: 10.0.0.0/16

### Prod Environment
- **Path**: `environments/prod/`
- **Instance Types**: t3.small (performance-optimized)
- **Instance Count**: 2 web servers, 1 database server
- **NAT Gateway**: Multi-AZ NAT Gateways
- **Network**: 10.1.0.0/16
- **Security**: No SSH access from internet

## Usage

### Deploy Dev Environment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy Prod Environment
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## Module Sources

All modules are sourced from:
- **Repository**: https://github.com/Kofijoo/terraform-aws-modules
- **Version**: v1.0.0
- **Modules**: vpc, ec2, security-group

## Remote State

Configure S3 backend for state management:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "environments/dev/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```