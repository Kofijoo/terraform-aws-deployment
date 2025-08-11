aws_region = "eu-north-1"
environment = "prod"

# Network Configuration - Different CIDR for prod
vpc_cidr               = "10.1.0.0/16"
availability_zones     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
public_subnet_cidrs    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs   = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
enable_nat_gateway     = true
single_nat_gateway     = false

# Instance Configuration - Production sizing
web_instance_count = 2
web_instance_type  = "t3.small"
db_instance_count  = 1
db_instance_type   = "t3.small"

# Security Group Rules - More restrictive SSH access
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
  }
]

db_ingress_rules = [
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
    description = "MySQL from VPC only"
  }
]

# User Data Scripts
web_user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Production Environment - Web Server</h1>" > /var/www/html/index.html
echo "<p>High Availability Deployment</p>" >> /var/www/html/index.html
echo "<p>Server: $(hostname)</p>" >> /var/www/html/index.html
EOF

db_user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb
# Production database hardening would go here
EOF

# Common Tags - Production specific
common_tags = {
  Environment   = "prod"
  Project       = "terraform-assignment"
  Owner         = "Joshua-Agyekum"
  CostCenter    = "Engineering"
  ManagedBy     = "Terraform"
  CreatedDate   = "2024-12-19"
  Purpose       = "Production-Environment"
  Criticality   = "High"
  Backup        = "Required"
  Monitoring    = "Required"
  CreatedBy     = "Joshua-Agyekum"
}