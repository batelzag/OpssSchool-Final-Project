# The name of the created S3 bucket
output "s3_bucket_name" {
  description = "The name of the created s3 bucket"
  value       = aws_s3_bucket.project-s3-remotestate.id
}

# The region of the created S3 bucket
output "s3_bucket_region" {
  description = "The region of the created s3 bucket"
  value       = aws_s3_bucket.project-s3-remotestate.region
}