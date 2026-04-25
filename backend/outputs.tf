output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "state_backend_config" {
  description = "Backend configuration to use in terraform files"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "${var.environment}/terraform.tfstate"
    region         = data.aws_region.current.name
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.id
  }
}
