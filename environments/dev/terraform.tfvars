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
apt install -y apache2 git wget unzip curl
systemctl start apache2
systemctl enable apache2

# Create game directory
mkdir -p /var/www/html/game
cd /var/www/html/game

# Clone the game repository
git clone https://github.com/Kofijoo/kid_game.github.io.git .

# Create welcome page with game link
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quest of the Sky Coders - Joshua's Game Server</title>
    <style>
        body { 
            font-family: 'Arial', sans-serif; 
            margin: 0; 
            padding: 40px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container { 
            background: rgba(255,255,255,0.95); 
            padding: 40px; 
            border-radius: 20px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            color: #333;
            max-width: 800px;
            margin: 0 auto;
        }
        h1 { 
            color: #4a5568; 
            text-align: center;
            margin-bottom: 10px;
        }
        .subtitle {
            text-align: center;
            color: #718096;
            margin-bottom: 30px;
            font-style: italic;
        }
        .game-link { 
            display: block;
            background: linear-gradient(45deg, #ff6b6b, #ee5a24);
            color: white; 
            padding: 20px 40px; 
            text-decoration: none; 
            border-radius: 50px; 
            margin: 30px auto;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            max-width: 300px;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .game-link:hover { 
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .info-card {
            background: #f7fafc;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #4299e1;
        }
        .features {
            margin-top: 30px;
        }
        .features ul {
            list-style: none;
            padding: 0;
        }
        .features li {
            padding: 8px 0;
            border-bottom: 1px solid #e2e8f0;
        }
        .features li:before {
            content: "🎮 ";
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⭐ Quest of the Sky Coders ⭐</h1>
        <p class="subtitle">A Professional AI-Adaptive Learning Game for Ages 9-11</p>
        
        <a href="/game/" class="game-link">🚀 Start Your Adventure!</a>
        
        <div class="features">
            <h3>🎯 Game Features:</h3>
            <ul>
                <li>Interactive Home Menu with Animated Characters</li>
                <li>6 Learning Islands: Fractions, Vocabulary, Geometry & More</li>
                <li>AI-Adaptive Difficulty System</li>
                <li>Progressive Hints with Audio Feedback</li>
                <li>Mobile Responsive Design</li>
                <li>Real-time Learning Analytics</li>
            </ul>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <strong>Server:</strong> dev-web-server
            </div>
            <div class="info-card">
                <strong>Environment:</strong> Development
            </div>
            <div class="info-card">
                <strong>Deployed via:</strong> Terraform Modules
            </div>
            <div class="info-card">
                <strong>Created by:</strong> Joshua Agyekum
            </div>
        </div>
    </div>
</body>
</html>
HTML

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Enable Apache modules for better performance
a2enmod rewrite
a2enmod headers
systemctl restart apache2
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