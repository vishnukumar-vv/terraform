output "ec2_instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.ec2.instance_ids
}

output "ec2_instance_private_ips" {
  description = "Private IPs of the EC2 instances"
  value       = module.ec2.instance_private_ips
}

output "ec2_instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = module.ec2.instance_public_ips
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2.security_group_id
}

output "ami_id" {
  description = "AMI ID used"
  value       = module.ec2.ami_id
}

output "static_file_bucket_name" {
  description = "Name of the S3 bucket containing the static file"
  value       = module.s3_static_file.bucket_name
}

output "static_file_bucket_arn" {
  description = "ARN of the S3 bucket containing the static file"
  value       = module.s3_static_file.bucket_arn
}

output "static_file_object_key" {
  description = "S3 object key for the uploaded static file"
  value       = module.s3_static_file.object_key
}
