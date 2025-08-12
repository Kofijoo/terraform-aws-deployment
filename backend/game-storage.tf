resource "aws_s3_bucket" "game_files" {
  bucket = "joshua-game-files-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Game Files Bucket"
    Environment = "shared"
    Owner       = "Joshua-Agyekum"
    Purpose     = "Game-File-Storage"
    ManagedBy   = "Terraform"
  }
}

# IAM role for EC2 instances to access game files
resource "aws_iam_role" "ec2_game_access" {
  name = "ec2-game-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "EC2 Game Access Role"
    Owner       = "Joshua-Agyekum"
    Purpose     = "Game-File-Access"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "game_files_access" {
  name        = "game-files-access-policy"
  description = "Policy for EC2 instances to access game files"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.game_files.arn,
          "${aws_s3_bucket.game_files.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_game_access" {
  role       = aws_iam_role.ec2_game_access.name
  policy_arn = aws_iam_policy.game_files_access.arn
}

resource "aws_iam_instance_profile" "ec2_game_access" {
  name = "ec2-game-access-profile"
  role = aws_iam_role.ec2_game_access.name
}