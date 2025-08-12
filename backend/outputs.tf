output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "backend_config" {
  description = "Backend configuration for copy-paste"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.bucket}"
        region         = "eu-north-1"
        dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
        encrypt        = true
      }
    }
  EOT
}

output "game_bucket_name" {
  description = "Name of the S3 bucket for game files"
  value       = aws_s3_bucket.game_files.bucket
}

output "game_bucket_url" {
  description = "URL of the S3 bucket for game files"
  value       = "https://${aws_s3_bucket.game_files.bucket}.s3.eu-north-1.amazonaws.com"
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 game access"
  value       = aws_iam_instance_profile.ec2_game_access.name
}