aws_region = "eu-north-1"
environment = "dev"

# Network Configuration
vpc_cidr               = "10.0.0.0/16"
availability_zones     = ["eu-north-1a", "eu-north-1b"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.10.0/24", "10.0.20.0/24"]
enable_nat_gateway     = true
single_nat_gateway     = true

# Instance Configuration
web_instance_count = 1
web_instance_type  = "t3.micro"
db_instance_count  = 1
db_instance_type   = "t3.micro"

# Security Group Rules
web_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from internet"
  }
]

db_ingress_rules = [
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "MySQL from VPC"
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "SSH from VPC"
  }
]

# User Data Scripts
web_user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Dev Environment - Web Server</h1>" > /var/www/html/index.html
echo "<p>Deployed via Terraform Modules</p>" >> /var/www/html/index.html
EOF

db_user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb
EOF

# Common Tags
common_tags = {
  Environment   = "dev"
  Project       = "terraform-assignment"
  Owner         = "Joshua-Agyekum"
  CostCenter    = "Engineering"
  ManagedBy     = "Terraform"
  CreatedDate   = "2024-12-19"
  Purpose       = "Development-Environment"
  CreatedBy     = "Joshua-Agyekum"
}