output "bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "object_key" {
  description = "Key of the uploaded static file."
  value       = aws_s3_object.static_file.key
}

output "object_etag" {
  description = "ETag of the uploaded static file."
  value       = aws_s3_object.static_file.etag
}
